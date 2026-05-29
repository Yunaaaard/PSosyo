import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:p_sosyo/app/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/database/tables/loan_items_table.dart';
import 'package:p_sosyo/app/services/payment_service.dart';
import 'package:p_sosyo/app/modules/home_screen/models/loan_order.dart';
import 'package:p_sosyo/app/widgets/loan_agreement_sheet.dart';
import 'package:p_sosyo/app/widgets/loan_details_sheet.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/pay_now.dart';
import 'package:p_sosyo/app/services/qr_scanner.dart';
import 'package:p_sosyo/app/services/user_phone_service.dart';
import 'package:p_sosyo/app/utils/principal_logo_resolver.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

class HomeController extends GetxController {
  final RxBool showAllBalanceCards = true.obs;

  static const double creditLimit = 25000.00;

  final RxDouble _maximumCreditLimitValue = creditLimit.obs;

  final RxList<LoanOrderCard> loanOrders = <LoanOrderCard>[].obs;
  final Rxn<LoanOrderCard> selectedLoanOrder = Rxn<LoanOrderCard>();
  final RxList<TransactionItem> transactionHistory = <TransactionItem>[].obs;
  late final PsosyoDatabaseService _database;
  late final UserPhoneService _userPhoneService;

  // Payment form state for QR payment page
  final RxString paymentReference = ''.obs;
  final Rxn<String> attachedReceiptPath = Rxn<String>();
  final RxString receiptOcrReferenceNumber = ''.obs;
  final RxString receiptOcrPhoneNumber = ''.obs;
  final RxString receiptOcrAmount = ''.obs;
  final RxString currentUserName = ''.obs;
  final TextEditingController paymentReferenceController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  late final Worker _paymentReferenceWorker;
  late final Worker _phoneNumberWorker;
  late final TextRecognizer _receiptTextRecognizer;
  // Pay Now UI bindings
  final RxBool useAutoReference = true.obs;
  final RxBool useAutoPhone = true.obs;
  final RxString phoneNumber = ''.obs;

  final List<String> remarksOptions = const [
    'Payment for order',
    'Partial payment',
    'Full payment',
  ];
  final RxString remarksValue = ''.obs;

  final List<String> paymentTypeOptions = const [
    'Cash',
    'GCash',
    'Bank Transfer',
    'Inventory Financing',
  ];
  final RxString selectedPaymentType = ''.obs;

  final List<LoanPrincipalOption> principalOptions = const [
    LoanPrincipalOption(
      title: 'Nestle',
      logoAsset:
          'https://raw.githubusercontent.com/Yunaaaard/PSosyo/main/assets/images/nestle-sample-logo.png',
    ),
    LoanPrincipalOption(
      title: 'Monde Nissin',
      logoAsset:
          'https://raw.githubusercontent.com/Yunaaaard/PSosyo/main/assets/images/monde-sample-logo.png',
    ),
    LoanPrincipalOption(
      title: 'Shell',
      logoAsset:
          'https://raw.githubusercontent.com/Yunaaaard/PSosyo/main/assets/images/shell-sample-logo.png',
    ),
    LoanPrincipalOption(
      title: 'Nutri Asia',
      logoAsset:
          'https://raw.githubusercontent.com/Yunaaaard/PSosyo/main/assets/images/nutriasia-sample-logo.png',
    ),
    LoanPrincipalOption(
      title: 'CDO',
      logoAsset:
          'https://raw.githubusercontent.com/Yunaaaard/PSosyo/main/assets/images/cdo-sample-logo.png',
    ),
  ];

  final List<int> paymentTermOptions = const [30, 60, 90];

  String get maximumCreditLimit =>
      _formatAmount(_maximumCreditLimitValue.value);
  double get availableCreditLimitValue => _maximumCreditLimitValue.value;

  LoanOrderCard? get activeLoanOrder =>
      selectedLoanOrder.value ??
      (loanOrders.isNotEmpty ? loanOrders.first : null);

  String get remainingBalance =>
      _formatAmount(activeLoanOrder?.remainingAmount ?? 0);

  final String distributorName = 'Fast Sosyo';
  String get principalName => activeLoanOrder?.title ?? 'Monde Nissin';
  String get loanId => activeLoanOrder?.loanId ?? 'AL-003MON';
  String get startPaymentDateTime =>
      activeLoanOrder?.appliedDateTime ?? '04-28-26 | 10:23';
  String get fullyPaidDateTime =>
      activeLoanOrder?.dueDateTime ?? '05-04-26 | 10:23';
  String get startingAmount =>
      _formatAmount(activeLoanOrder?.originalAmount ?? 0);
  String get orderedAmount =>
      _formatAmount(activeLoanOrder?.remainingAmount ?? 0);
  final String interestRate = '1%';
  final String processingFee = '2.5%';

  String get repaymentProgress => activeLoanOrder?.remainingPercentText ?? '0%';
  double get repaymentProgressValue =>
      activeLoanOrder?.remainingPercentValue ?? 0;

  @override
  void onInit() {
    super.onInit();
    _database = Get.find<PsosyoDatabaseService>();
    _userPhoneService = Get.find<UserPhoneService>();
    _receiptTextRecognizer = TextRecognizer();
    paymentReferenceController.text = paymentReference.value;
    phoneNumberController.text = phoneNumber.value;
    _paymentReferenceWorker = ever<String>(paymentReference, (value) {
      final text = value;
      if (paymentReferenceController.text != text) {
        paymentReferenceController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
    _phoneNumberWorker = ever<String>(phoneNumber, (value) {
      final text = value;
      if (phoneNumberController.text != text) {
        phoneNumberController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
    unawaited(_bootstrapFromDatabase());
    unawaited(_bootstrapCurrentUser());
    // TextEditingControllers for Pay Now are managed by the PayNowPage widget.
  }

  @override
  void onClose() {
    _paymentReferenceWorker.dispose();
    _phoneNumberWorker.dispose();
    _receiptTextRecognizer.close();
    paymentReferenceController.dispose();
    phoneNumberController.dispose();
    // UI controllers are disposed by their owning widget.
    super.onClose();
  }

  Future<void> _bootstrapFromDatabase() async {
    final savedLoans = await _database.loadActiveLoanOrders();
    loanOrders.assignAll(savedLoans);
    final routeSelectedLoanId = _selectedLoanIdFromRoute();
    if (routeSelectedLoanId != null && _selectLoanOrderById(routeSelectedLoanId)) {
      showAllBalanceCards.value = true;
    } else {
      selectedLoanOrder.value = savedLoans.isNotEmpty ? savedLoans.first : null;
    }
    _syncAvailableCredit();

    // Load persisted loan orders and payment requests, then rebuild transaction history.
    try {
      final loanRows = await _database.loadAllLoanOrders();
      final paymentRows = await _database.loadPaymentRequests(limit: 100);
      final loanLogoById = <String, String>{
        for (final loan in loanRows)
          if (loan.loanId.trim().isNotEmpty) loan.loanId.trim(): loan.logoAsset,
      };

      final items = <_HistoryEntry>[];

      for (final loan in loanRows) {
        items.add(
          _HistoryEntry(
            sortKey: loan.appliedAt,
            item: TransactionItem(
              title: 'Loan Order',
              dateTime: formatLoanDate(loan.appliedAt),
              amount: _formatAmount(loan.originalAmount),
              sign: '- ',
              status: 'SUCCESS',
              logoAsset: loan.logoAsset,
            ),
          ),
        );
      }

      for (final row in paymentRows) {
        final amount = double.tryParse(row['amount']?.toString() ?? '') ?? 0.0;
        final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now();
        final loanId = row['loan_id']?.toString();
        final reference = row['reference_id']?.toString();
        final status = row['status']?.toString() ?? 'SUCCESS';
        final logoAsset = _safeLogoAsset(
          loanId != null && loanLogoById.containsKey(loanId.trim())
              ? loanLogoById[loanId.trim()]
              : _logoAssetFromMetadata(row['metadata_json']?.toString()),
        );
        final title = (loanId != null && loanId.isNotEmpty)
            ? 'Loan Payment - $loanId'
            : (reference != null && reference.isNotEmpty)
                ? 'Payment - $reference'
                : 'Payment';

        items.add(
          _HistoryEntry(
            sortKey: createdAt,
            item: TransactionItem(
              title: title,
              dateTime: formatLoanDate(createdAt),
              amount: _formatAmount(amount),
              sign: '+ ',
              status: status,
              logoAsset: logoAsset,
            ),
          ),
        );
      }

      items.sort((a, b) => b.sortKey.compareTo(a.sortKey));
      transactionHistory.assignAll(items.map((entry) => entry.item));
    } catch (_) {
      // Ignore DB errors here; transactionHistory will remain empty if load fails.
    }
  }

  Future<void> _bootstrapCurrentUser() async {
    var registeredPhone = _userPhoneService.getRegisteredPhone();
    if (registeredPhone.isEmpty) {
      registeredPhone = (await _database.loadLatestRegisteredPhone()) ?? '';
      if (registeredPhone.isNotEmpty) {
        _userPhoneService.setRegisteredPhone(registeredPhone);
      }
    }
    if (registeredPhone.isNotEmpty) {
      phoneNumber.value = registeredPhone;
    }

    final loadedName = await _database.loadUserFullName(phoneNumber: registeredPhone);
    if (loadedName != null && loadedName.trim().isNotEmpty) {
      currentUserName.value = loadedName.trim();
    }
  }

  void _syncAvailableCredit() {
    final remainingTotal = loanOrders.fold<double>(
      0,
      (sum, order) => sum + order.remainingAmount,
    );
    _maximumCreditLimitValue.value =
        (creditLimit - remainingTotal).clamp(0, creditLimit).toDouble();
  }

  void openPayNowPage([LoanOrderCard? order]) {
    final selectedOrder = order ?? activeLoanOrder;
    if (selectedOrder == null) {
      return;
    }

    selectedLoanOrder.value = selectedOrder;
    Get.to(() => const PayNowPage());
  }

  void openQrScannerPage() {
    Get.to(() => const QrScannerPage());
  }

  Future<void> openReceiptCaptureUploadOptions() async {
    await Get.bottomSheet(
      SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E6EE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Attach E-receipt Photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F333A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Capture a new photo or upload one from your gallery.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C828E),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Get.back();
                    await _attachReceiptFromCamera();
                  },
                  style: AppThemes.primaryButtonStyle,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Capture Photo'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Get.back();
                    await _attachReceiptFromGallery();
                  },
                  style: AppThemes.primaryButtonStyle,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Upload Photo'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _attachReceiptFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }

    await _attachReceiptAndReadOcr(image);
  }

  Future<void> _attachReceiptFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    await _attachReceiptAndReadOcr(image);
  }

  Future<void> _attachReceiptAndReadOcr(XFile image) async {
    attachReceipt(image.path);
    receiptOcrReferenceNumber.value = '';
    receiptOcrPhoneNumber.value = '';
    receiptOcrAmount.value = '';

    try {
      final recognized = await _readReceiptOcr(image.path);
      final reference = recognized.referenceNumber?.trim() ?? '';
      final phoneNumber = recognized.phoneNumber?.trim() ?? '';
      final amount = recognized.amount;

      receiptOcrReferenceNumber.value = reference;
      receiptOcrPhoneNumber.value = phoneNumber;
      receiptOcrAmount.value = amount != null ? _formatAmount(amount) : '';

      if (reference.isEmpty && amount == null) {
        await _showReceiptOcrDialog(
          referenceNumber: null,
          phoneNumber: null,
          amountText: null,
          isSuccess: false,
        );
        return;
      }

      if (reference.isNotEmpty) {
        useAutoReference.value = false;
        paymentReference.value = reference;
        paymentReferenceController.text = reference;
      }

      if (phoneNumber.isNotEmpty) {
        useAutoPhone.value = false;
        this.phoneNumber.value = phoneNumber;
        phoneNumberController.text = phoneNumber;
      }

      await _showReceiptOcrDialog(
        referenceNumber: reference.isEmpty ? null : reference,
        phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
        amountText: amount == null ? null : _formatAmount(amount),
        isSuccess: true,
      );
    } catch (e) {
      await _showReceiptOcrDialog(
        referenceNumber: null,
        phoneNumber: null,
        amountText: null,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<_ReceiptOcrResult> _readReceiptOcr(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final recognizedText = await _receiptTextRecognizer.processImage(inputImage);
    return _extractReceiptOcrResult(recognizedText.text);
  }

  _ReceiptOcrResult _extractReceiptOcrResult(String rawText) {
    final lines = _splitReceiptLines(rawText);
    final reference = _extractReceiptReference(lines);
    final phoneNumber = _extractReceiptPhoneNumber(lines);
    final amount = _extractReceiptAmount(lines);

    return _ReceiptOcrResult(
      referenceNumber: reference,
      phoneNumber: phoneNumber,
      amount: amount,
    );
  }

  String? _extractReceiptReference(List<String> lines) {
    for (var index = 0; index < lines.length; index++) {
      final current = lines[index];
      if (!_isReferenceLabel(current)) {
        continue;
      }

      final sameLine = _stripLabelPrefix(current, _referenceLabelPatterns);
      final nextLine = index + 1 < lines.length ? lines[index + 1] : '';
      final candidate = sameLine.isNotEmpty ? sameLine : nextLine;
      final digits = _extractReferenceDigits(candidate);
      if (digits.length >= 10) {
        return _formatReferenceDigits(digits);
      }
    }

    return null;
  }

  double? _extractReceiptAmount(List<String> lines) {
    for (var index = 0; index < lines.length; index++) {
      final current = lines[index];
      if (!_isAmountLabel(current)) {
        continue;
      }

      final sameLine = _stripLabelPrefix(current, _amountLabelPatterns);
      final sameLineAmount = _extractAmountFromText(sameLine);
      if (sameLineAmount != null) {
        return sameLineAmount;
      }

      if (index + 1 < lines.length) {
        final nextLine = lines[index + 1];
        if (_isLikelyAmountLine(nextLine)) {
          final nextAmount = _extractAmountFromText(nextLine);
          if (nextAmount != null) {
            return nextAmount;
          }
        }
      }

      if (index + 2 < lines.length) {
        final skipLine = lines[index + 2];
        if (_isLikelyAmountLine(skipLine)) {
          final skipAmount = _extractAmountFromText(skipLine);
          if (skipAmount != null) {
            return skipAmount;
          }
        }
      }
    }

    final fallbackValues = <double>[];
    for (var index = 0; index < lines.length; index++) {
      final current = lines[index];
      if (!_isLikelyAmountLine(current)) {
        continue;
      }

      final parsed = _extractAmountFromText(current);
      if (parsed != null) {
        fallbackValues.add(parsed);
      }

      if (index + 1 < lines.length && _isLikelyAmountLine(lines[index + 1])) {
        final nextParsed = _extractAmountFromText(lines[index + 1]);
        if (nextParsed != null) {
          fallbackValues.add(nextParsed);
        }
      }
    }

    if (fallbackValues.isEmpty) {
      return null;
    }

    fallbackValues.sort((a, b) => b.compareTo(a));
    return fallbackValues.first;
  }

  String? _extractReceiptPhoneNumber(List<String> lines) {
    for (final line in lines) {
      final phone = _extractPlus63PhoneNumber(line);
      if (phone != null) {
        return phone;
      }
    }

    return null;
  }

  String? _extractPlus63PhoneNumber(String text) {
    final normalized = _normalizeOcrWhitespace(text);
    if (normalized.isEmpty) {
      return null;
    }

    final match = RegExp(r'(?:\+63|63)[\s\-()]*(9\d{2})[\s\-()]*?(\d{3})[\s\-()]*?(\d{4})').firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final prefix = match.group(1);
    final middle = match.group(2);
    final last = match.group(3);
    if (prefix == null || middle == null || last == null) {
      return null;
    }

    return '+63 $prefix $middle $last';
  }

  double? _extractAmountFromText(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final hasMoneyMarker =
        normalized.contains('₱') ||
        normalized.toLowerCase().contains('php') ||
        normalized.toLowerCase().contains('p ');
    final hasDecimalOrGrouping =
        normalized.contains('.') || normalized.contains(',');

    if (!hasMoneyMarker && !hasDecimalOrGrouping) {
      return null;
    }

    final amountRegex = RegExp(
      r'(?:₱|php|p)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2})?)|([0-9]+\.[0-9]{2})',
      caseSensitive: false,
    );
    final match = amountRegex.firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final value = match.group(1) ?? match.group(2) ?? '';
    final cleaned = value.replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }

  bool _isReferenceLabel(String value) {
    final normalized = value.toLowerCase();
    return _referenceLabelPatterns.any((pattern) => pattern.hasMatch(normalized));
  }

  bool _isAmountLabel(String value) {
    final normalized = value.toLowerCase();
    return _amountLabelPatterns.any((pattern) => pattern.hasMatch(normalized));
  }

  bool _isLikelyAmountSectionLine(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('amount') ||
        normalized.contains('sent') ||
        normalized.contains('php') ||
        normalized.contains('₱');
  }

  String _formatReferenceDigits(String digits) {
    final cleaned = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) {
      return digits;
    }

    if (cleaned.length == 13) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    }

    final buffer = StringBuffer();
    for (var index = 0; index < cleaned.length; index++) {
      buffer.write(cleaned[index]);
      if ((index + 1) % 4 == 0 && index != cleaned.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  List<String> _splitReceiptLines(String rawText) {
    return rawText
        .replaceAll('\r', '\n')
        .split(RegExp(r'\n+'))
        .map((line) => _normalizeOcrWhitespace(line))
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String _extractReferenceDigits(String text) {
    final normalized = _normalizeOcrWhitespace(text);
    if (normalized.isEmpty) {
      return '';
    }

    final match = RegExp(r'^[0-9][0-9\s-]*').firstMatch(normalized);
    if (match != null) {
      return match.group(0)?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    }

    final looseMatch = RegExp(r'(\d[\d\s-]{7,}\d)').firstMatch(normalized);
    if (looseMatch != null) {
      return looseMatch.group(1)?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    }

    return '';
  }

  String get displayOcrAmount => receiptOcrAmount.value;

  String get displayOcrReferenceNumber => receiptOcrReferenceNumber.value;

  final List<RegExp> _referenceLabelPatterns = [
    RegExp(r'\bref\s*no\.?\b', caseSensitive: false),
    RegExp(r'\breference\s*no\.?\b', caseSensitive: false),
  ];

  final List<RegExp> _amountLabelPatterns = [
    RegExp(r'\btotal\s*amount\s*sent\b', caseSensitive: false),
  ];

  String _normalizeOcrWhitespace(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _isLikelyAmountLine(String value) {
    final normalized = value.toLowerCase();
    return _isLikelyAmountSectionLine(normalized) ||
        RegExp(r'\b[0-9]{1,3}(?:,[0-9]{3})*\.[0-9]{2}\b').hasMatch(normalized) ||
        normalized.contains('₱');
  }

  String _stripLabelPrefix(String value, List<RegExp> patterns) {
    var output = value.trim();
    for (final pattern in patterns) {
      output = output.replaceFirst(pattern, '').trim();
    }
    output = output.replaceFirst(RegExp(r'^[:\-\s]+'), '').trim();
    return output;
  }

  Future<void> _showReceiptOcrDialog({
    required String? referenceNumber,
    required String? phoneNumber,
    required String? amountText,
    required bool isSuccess,
    String? errorMessage,
  }) async {
    await Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isSuccess ? const Color(0xFFEAF1FF) : const Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.receipt_long_rounded : Icons.info_outline_rounded,
                  color: isSuccess ? const Color(0xFF2E5DC8) : const Color(0xFFEA4335),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess ? 'Receipt details detected' : 'Receipt text not recognized',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSuccess
                    ? 'Only Ref No. and Total Amount Sent from the GCash receipt were read.'
                    : (errorMessage?.trim().isNotEmpty == true
                        ? errorMessage!
                        : 'Make sure the receipt is clear and includes Ref No. and Total Amount Sent.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF6D7480),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              if (referenceNumber != null) ...[
                _ReceiptDetailRow(label: 'Ref No.', value: referenceNumber),
                const SizedBox(height: 10),
              ],
              if (phoneNumber != null) ...[
                _ReceiptDetailRow(label: 'Phone Number', value: phoneNumber),
                const SizedBox(height: 10),
              ],
              if (amountText != null) ...[
                _ReceiptDetailRow(
                  label: 'Total Amount Sent',
                  valueWidget: PesoFormatter.buildPesoText(
                    amount: amountText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2430),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: AppThemes.primaryButtonStyle,
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void openLoanAgreementSheet() {
    Get.bottomSheet(
      const LoanAgreementSheet(),
      isScrollControlled: true,
    );
  }

  void toggleBalanceCardsVisibility() {
    showAllBalanceCards.toggle();
  }

  Future<bool> importLoanOrderFromQrPayload(String rawPayload) async {
    final userPhone = Get.find<UserPhoneService>().getRegisteredPhone();
    final decodedPayload = _decodeQrPayload(rawPayload);

    if (decodedPayload != null && _looksLikeImportableLoanPayload(decodedPayload)) {
      final result = await _database.importLoanOrderPayload(
        decodedPayload,
        userPhone: userPhone,
        rawPayload: rawPayload,
      );

      if (!result.success || result.loanOrder == null) {
        Get.snackbar(
          'Loan blocked',
          result.message ?? 'The scanned QR code could not be imported.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final savedLoans = await _database.loadActiveLoanOrders();
      loanOrders.assignAll(savedLoans);
      _selectLoanOrderById(result.loanOrder!.loanId);
      _syncAvailableCredit();
      transactionHistory.insert(
        0,
        TransactionItem(
          title: 'Loan Order',
          dateTime: formatLoanDate(result.loanOrder!.appliedAt),
          amount: _formatAmount(result.loanOrder!.originalAmount),
          sign: '- ',
          status: 'SUCCESS',
          logoAsset: result.loanOrder!.logoAsset,
        ),
      );
      return true;
    }

    final loanId = _extractLoanIdFromPayload(rawPayload, decodedPayload);
    if (loanId != null) {
      final storedLoan = await _database.loadLoanOrderByLoanId(loanId);
      if (storedLoan != null) {
        final savedLoans = await _database.loadActiveLoanOrders();
        loanOrders.assignAll(savedLoans);
        _selectLoanOrderById(storedLoan.loanId);
        _syncAvailableCredit();
        return true;
      }

      final trimmed = rawPayload.trim();
      final uri = Uri.tryParse(trimmed);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        try {
          final resp = await http.get(uri).timeout(const Duration(seconds: 8));
          if (resp.statusCode == 200 && resp.body.trim().isNotEmpty) {
            try {
              final decodedRemote = jsonDecode(resp.body);
              // Some hosts wrap the record payload (e.g., jsonbin.io)
              final payload = decodedRemote is Map && decodedRemote.containsKey('record')
                  ? decodedRemote['record']
                  : decodedRemote;

              if (payload is Map<String, dynamic>) {
                final result = await _database.importLoanOrderPayload(
                  Map<String, dynamic>.from(payload),
                  userPhone: userPhone,
                  rawPayload: resp.body,
                );

                if (result.success && result.loanOrder != null) {
                  final savedLoans = await _database.loadActiveLoanOrders();
                  loanOrders.assignAll(savedLoans);
                  _selectLoanOrderById(result.loanOrder!.loanId);
                  _syncAvailableCredit();
                  return true;
                }
              }
            } catch (_) {
              // If JSON decode failed, try importing raw JSON string.
              final fallback = await _database.importLoanOrderFromRawJson(
                resp.body,
                userPhone: userPhone,
              );
              if (fallback.success && fallback.loanOrder != null) {
                final savedLoans = await _database.loadActiveLoanOrders();
                loanOrders.assignAll(savedLoans);
                _selectLoanOrderById(fallback.loanOrder!.loanId);
                _syncAvailableCredit();
                return true;
              }
            }
          }
        } catch (_) {}
      }

      if (decodedPayload == null) {
        Get.snackbar(
          'Loan not found',
          'The scanned QR only contains a loan ID, but that loan is not stored locally yet.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    if (decodedPayload != null) {
      Get.snackbar(
        'Unsupported QR',
        'The scanned QR does not include enough loan details to import or resolve locally.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final result = await _database.importLoanOrderFromRawJson(
      rawPayload,
      userPhone: userPhone,
    );

    if (!result.success || result.loanOrder == null) {
      Get.snackbar(
        'Loan blocked',
        result.message ?? 'The scanned QR code could not be imported.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final savedLoans = await _database.loadActiveLoanOrders();
    loanOrders.assignAll(savedLoans);
    _selectLoanOrderById(result.loanOrder!.loanId);
    _syncAvailableCredit();
    transactionHistory.insert(
      0,
      TransactionItem(
        title: 'Loan Order',
        dateTime: formatLoanDate(result.loanOrder!.appliedAt),
        amount: _formatAmount(result.loanOrder!.originalAmount),
        sign: '- ',
        status: 'SUCCESS',
        logoAsset: result.loanOrder!.logoAsset,
      ),
    );
    return true;
  }

  bool _selectLoanOrderById(String loanId) {
    final index = loanOrders.indexWhere((order) => order.loanId == loanId);
    if (index == -1) {
      return false;
    }

    final selectedOrder = loanOrders[index];
    if (index != 0) {
      loanOrders.removeAt(index);
      loanOrders.insert(0, selectedOrder);
    }

    selectedLoanOrder.value = selectedOrder;
    showAllBalanceCards.value = true;
    return true;
  }

  String? _selectedLoanIdFromRoute() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final rawValue = args['selectedLoanId'] ?? args['loanId'];
      final loanId = rawValue?.toString().trim() ?? '';
      return loanId.isEmpty ? null : loanId;
    }

    if (args is String) {
      final loanId = args.trim();
      return loanId.isEmpty ? null : loanId;
    }

    return null;
  }

  bool _looksLikeImportableLoanPayload(Map<String, dynamic> payload) {
    final loanId = _findString(payload, ['loanId', 'loan_id', 'id']);
    final principalTitle =
        _findString(payload, ['principalTitle', 'principal_title', 'title']);
    final dueDate = _findDate(payload, ['dueDate', 'due_date']);
    final amountDue = _findAmount(payload, ['amountDue', 'amount_due', 'amount']);
    final products = payload['products'];

    return loanId != null &&
        principalTitle != null &&
        dueDate != null &&
        (amountDue != null || products is List);
  }

  String? _extractLoanIdFromPayload(
    String rawPayload,
    Map<String, dynamic>? decodedPayload,
  ) {
    final fromJson = decodedPayload == null
        ? null
        : _findString(decodedPayload, ['loanId', 'loan_id', 'id']);
    if (fromJson != null) {
      return fromJson;
    }

    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      for (final key in <String>['loanId', 'loan_id', 'id']) {
        final value = uri.queryParameters[key];
        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      final lastSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (lastSegment.trim().isNotEmpty) {
        return lastSegment.trim();
      }
    }

    return trimmed;
  }

  Map<String, dynamic>? _decodeQrPayload(String rawPayload) {
    try {
      final decoded = jsonDecode(_normalizeJsonPayload(rawPayload));
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      final extracted = _extractJsonObject(rawPayload);
      if (extracted == null) {
        return null;
      }

      try {
        final decoded = jsonDecode(_normalizeJsonPayload(extracted));
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final loose = _extractLooseLoanPayload(rawPayload);
    if (loose.isNotEmpty) {
      return loose;
    }
    return null;
  }

  String? _extractJsonObject(String rawPayload) {
    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final fenceStripped = trimmed
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();

    if (fenceStripped.startsWith('{') && fenceStripped.endsWith('}')) {
      return fenceStripped;
    }

    final startIndex = fenceStripped.indexOf('{');
    if (startIndex == -1) {
      return null;
    }

    var depth = 0;
    for (var index = startIndex; index < fenceStripped.length; index++) {
      final char = fenceStripped[index];
      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) {
          return fenceStripped.substring(startIndex, index + 1);
        }
      }
    }

    return null;
  }

  String _normalizeJsonPayload(String rawPayload) {
    return rawPayload.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
  }

  Map<String, dynamic> _extractLooseLoanPayload(String rawPayload) {
    final normalized = rawPayload.replaceAll('\r', '');
    final payload = <String, dynamic>{};

    String? matchString(String pattern) {
      final match =
          RegExp(pattern, multiLine: true, dotAll: true).firstMatch(normalized);
      if (match == null) {
        return null;
      }

      return match.group(1)?.trim();
    }

    payload['loanId'] = matchString(r'"loanId"\s*:\s*"([^"]+)"');
    payload['principalTitle'] =
        matchString(r'"principalTitle"\s*:\s*"([^"]+)"');
    payload['amountDue'] = matchString(r'"amountDue"\s*:\s*([^,}\n]+)');
    payload['appliedDate'] = matchString(r'"appliedDate"\s*:\s*"([^"]+)"');
    payload['dueDate'] = matchString(r'"dueDate"\s*:\s*"([^"]+)"');

    payload.removeWhere(
        (key, value) => value == null || value.toString().trim().isEmpty);
    return payload;
  }

  LoanOrderCard? _loanOrderFromQrPayload(Map<String, dynamic> payload) {
    final loanId = _findString(payload, ['loanId', 'loan_id', 'id']);
    final principalTitle =
        _findString(payload, ['principalTitle', 'principal_title', 'title']);
    final principalLogo = principalLogoUrlForTitle(principalTitle);
    final amountDue =
        _findAmount(payload, ['amountDue', 'amount_due', 'amount']);
    final appliedDate = DateTime.now();
    final dueDate = _findDate(payload, ['dueDate', 'due_date']);

    if (loanId == null ||
        principalTitle == null ||
        principalLogo == null ||
        amountDue == null ||
        dueDate == null) {
      return null;
    }

    return LoanOrderCard(
      title: principalTitle,
      loanId: loanId,
      logoAsset: principalLogo,
      appliedAt: appliedDate,
      dueAt: dueDate,
      originalAmount: amountDue,
      remainingAmount: amountDue,
    );
  }

  String? _findString(Map<String, dynamic> payload, List<String> keys) {
    final value = _findValue(payload, keys);
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  double? _findAmount(Map<String, dynamic> payload, List<String> keys) {
    final value = _findValue(payload, keys);
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    final cleaned =
        value.toString().replaceAll(',', '').replaceAll('₱', '').trim();
    return double.tryParse(cleaned);
  }

  DateTime? _findDate(Map<String, dynamic> payload, List<String> keys) {
    final value = _findValue(payload, keys);
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    final direct = DateTime.tryParse(raw);
    if (direct != null) {
      return direct;
    }

    final normalized = raw.replaceAll(RegExp(r'\s+\|\s+.*$'), '');
    return DateTime.tryParse(normalized);
  }

  dynamic _findValue(Map<String, dynamic> payload, List<String> keys) {
    final normalizedKeys = keys.map((key) => key.toLowerCase()).toSet();

    dynamic search(dynamic value) {
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        for (final entry in map.entries) {
          final key = entry.key.toString().toLowerCase();
          if (normalizedKeys.contains(key)) {
            return entry.value;
          }
        }

        for (final entry in map.entries) {
          final nested = search(entry.value);
          if (nested != null) {
            return nested;
          }
        }
      } else if (value is List) {
        for (final item in value) {
          final nested = search(item);
          if (nested != null) {
            return nested;
          }
        }
      }
      return null;
    }

    return search(payload);
  }

  Future<bool> submitLoanOrder({
    required LoanPrincipalOption principal,
    required double amount,
    required int termDays,
    DateTime? appliedAt,
    bool seed = false,
  }) async {
    final createdAt = appliedAt ?? DateTime.now();

    if (amount <= 0) {
      if (!seed) {
        Get.snackbar(
          'Invalid amount',
          'Enter a loan amount greater than zero.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }

    if (amount > _maximumCreditLimitValue.value) {
      if (!seed) {
        Get.snackbar(
          'Credit limit exceeded',
          'Loan orders must stay within your ₱25,000 credit limit.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }

    // Prevent creating a new loan order for the same principal while an existing
    // loan for that principal still has a remaining balance.
    final hasOutstanding = loanOrders
        .any((lo) => lo.title == principal.title && lo.remainingAmount > 0);
    if (hasOutstanding) {
      if (!seed) {
        Get.snackbar(
          'Existing balance',
          'You have an outstanding balance for ${principal.title}. Pay it off before creating another order for the same brand.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }

    final loanSequence = await _database.nextLoanSequence();
    final dueAt = createdAt.add(Duration(days: termDays));
    final loanOrder = LoanOrderCard(
      title: principal.title,
      loanId: buildLoanId(loanSequence, principal.code),
      logoAsset: principal.logoAsset,
      appliedAt: createdAt,
      dueAt: dueAt,
      originalAmount: amount,
      remainingAmount: amount,
    );

    loanOrders.insert(0, loanOrder);
    selectedLoanOrder.value = loanOrder;
    _syncAvailableCredit();

    try {
      await _database.saveLoanOrderCard(
        loanOrder,
        userPhone: Get.find<UserPhoneService>().getRegisteredPhone(),
      );
    } catch (e) {
      loanOrders.removeWhere((order) => order.loanId == loanOrder.loanId);
      selectedLoanOrder.value = loanOrders.isNotEmpty ? loanOrders.first : null;
      _syncAvailableCredit();
      if (!seed) {
        Get.snackbar(
          'Database error',
          'Unable to save the loan locally: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }

    if (!seed) {
      transactionHistory.insert(
        0,
        TransactionItem(
          title: 'Loan Order',
          dateTime: formatLoanDate(createdAt),
          amount: _formatAmount(amount),
          sign: '- ',
          status: 'SUCCESS',
          logoAsset: principal.logoAsset,
        ),
      );
    }

    return true;
  }

  Future<bool> submitLoanOrdersByAllocation({
    required Map<LoanPrincipalOption, double> allocations,
    required int termDays,
    DateTime? appliedAt,
  }) async {
    if (allocations.isEmpty) {
      Get.snackbar(
        'Invalid allocation',
        'Select at least one brand allocation.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final totalPercent =
        allocations.values.fold<double>(0, (sum, value) => sum + value);
    if (totalPercent <= 0.001) {
      Get.snackbar(
        'Invalid allocation',
        'Select at least one brand allocation greater than 0%.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (totalPercent > 100.001) {
      Get.snackbar(
        'Invalid allocation',
        'Brand percentages must not exceed 100%.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final available = _maximumCreditLimitValue.value;
    if (available <= 0) {
      Get.snackbar(
        'Credit unavailable',
        'No available credit limit to allocate.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final entries =
        allocations.entries.where((entry) => entry.value > 0).toList();
    if (entries.isEmpty) {
      Get.snackbar(
        'Invalid allocation',
        'At least one brand must have a percentage greater than 0%.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Ensure none of the selected principals already have outstanding balances.
    final blocked = <String>[];
    for (final entry in entries) {
      final principal = entry.key;
      final existsOutstanding = loanOrders
          .any((lo) => lo.title == principal.title && lo.remainingAmount > 0);
      if (existsOutstanding) {
        blocked.add(principal.title);
      }
    }
    if (blocked.isNotEmpty) {
      Get.snackbar(
        'Existing balances',
        'Cannot create orders for: ${blocked.join(', ')}. Pay existing balances first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final amounts = <double>[];
    for (var index = 0; index < entries.length; index++) {
      final percent = entries[index].value;
      final amount =
          double.parse((available * (percent / 100)).toStringAsFixed(2));
      amounts.add(amount);
    }

    for (var index = 0; index < entries.length; index++) {
      final principal = entries[index].key;
      final amount = amounts[index];
      if (amount <= 0) {
        continue;
      }
      final success = await submitLoanOrder(
        principal: principal,
        amount: amount,
        termDays: termDays,
        appliedAt: appliedAt,
      );
      if (!success) {
        return false;
      }
    }

    return true;
  }

  Future<void> recordLoanPaymentSuccess({
    required LoanOrderCard order,
    required double amount,
    String? paymentReferenceId,
    String? paymentRequestId,
    String? paymentMethod,
    DateTime? when,
  }) async {
    final createdAt = when ?? DateTime.now();

    final paidAmount =
        amount > order.remainingAmount ? order.remainingAmount : amount;
    if (paidAmount <= 0) {
      return;
    }

    order.remainingAmount = (order.remainingAmount - paidAmount)
        .clamp(0, double.infinity)
        .toDouble();
    _maximumCreditLimitValue.value =
        (_maximumCreditLimitValue.value + paidAmount)
            .clamp(0, creditLimit)
            .toDouble();

    if (order.remainingAmount <= 0) {
      loanOrders.removeWhere((loanOrder) => loanOrder.loanId == order.loanId);
      if (selectedLoanOrder.value?.loanId == order.loanId) {
        selectedLoanOrder.value =
            loanOrders.isNotEmpty ? loanOrders.first : null;
      }
    } else {
      loanOrders.refresh();
      if (selectedLoanOrder.value?.loanId == order.loanId) {
        selectedLoanOrder.refresh();
      }
    }

    _syncAvailableCredit();
    await _database.applyLoanPayment(
      loanId: order.loanId,
      paidAmount: paidAmount,
      remainingAmount: order.remainingAmount,
    );

    // Persist a payment request record so transaction history survives app restarts
    try {
      final nowIso = createdAt.toIso8601String();
      final localPaymentRequestId = paymentRequestId ??
          'pr-local-${DateTime.now().millisecondsSinceEpoch}';
      final localPaymentReferenceId = paymentReferenceId?.trim().isNotEmpty == true
          ? paymentReferenceId!.trim()
          : 'PAY-${DateTime.now().millisecondsSinceEpoch}';
      final selectedMethod = paymentMethod?.trim().isNotEmpty == true
          ? paymentMethod!.trim()
          : selectedPaymentType.value.trim();
      final payload = <String, dynamic>{
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'loan_id': order.loanId,
        'reference_id': localPaymentReferenceId,
        'payment_request_id': localPaymentRequestId,
        if (selectedMethod.isNotEmpty)
          'payment_method': <String, dynamic>{
            'method': selectedMethod,
          },
        'metadata': <String, dynamic>{
          if (selectedMethod.isNotEmpty) 'payment_method_label': selectedMethod,
          'remarks': remarksValue.value.trim(),
          'phone_number': phoneNumber.value.trim(),
          'customer_name': currentUserName.value.trim(),
          'payment_reference_id': localPaymentReferenceId,
          'payment_request_id': localPaymentRequestId,
          'loan_id': order.loanId,
        },
        'amount': paidAmount,
        'status': 'SUCCESS',
        'created': nowIso,
        'updated': nowIso,
      };
      await _database.savePaymentRequest(payload, loanId: order.loanId);
    } catch (_) {}

    transactionHistory.insert(
      0,
      TransactionItem(
        title: 'Loan Payment - ${order.title}',
        dateTime: formatLoanDate(createdAt),
        amount: _formatAmount(paidAmount),
        sign: '+ ',
        status: 'SUCCESS',
        logoAsset: order.logoAsset,
      ),
    );
  }

  Future<void> openLoanDetailsSheet(LoanOrderCard order) async {
    final List<LoanItemRecord> items =
        await _database.loadLoanItemsForLoan(order.loanId);

    Get.bottomSheet(
      LoanDetailsSheet(
        principalTitle: order.title,
        loanId: order.loanId,
        appliedDateTime: order.appliedDateTime,
        dueDateTime: order.dueDateTime,
        amountDue: order.amountDueText,
        items: items,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Processes payment through [PaymentService] then records it locally on success.
  Future<bool> processPayment({
    required LoanOrderCard order,
    required double amount,
    String? paymentReferenceId,
    String? paymentMethod,
    String? receiptPath,
    bool allowLocalFallback = false,
  }) async {
    final service = PaymentService();
    try {
      final success = await service.processPayment(
        loanId: order.loanId,
        amount: amount,
        paymentReferenceId: paymentReferenceId,
        receiptPath: receiptPath,
      );

      if (success) {
        await recordLoanPaymentSuccess(
          order: order,
          amount: amount,
          paymentReferenceId: paymentReferenceId,
          paymentRequestId:
              'pr-local-${DateTime.now().millisecondsSinceEpoch}',
          paymentMethod: paymentMethod,
        );
        return true;
      }

      if (allowLocalFallback) {
        await recordLoanPaymentSuccess(
          order: order,
          amount: amount,
          paymentReferenceId: paymentReferenceId,
          paymentRequestId:
              'pr-local-${DateTime.now().millisecondsSinceEpoch}',
          paymentMethod: paymentMethod,
        );
        Get.snackbar(
          'Payment Completed',
          'QR matched the active loan and payment was recorded locally.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }

      Get.snackbar('Payment Failed', 'Unable to process payment.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      if (allowLocalFallback) {
        await recordLoanPaymentSuccess(
          order: order,
          amount: amount,
          paymentReferenceId: paymentReferenceId,
          paymentRequestId:
              'pr-local-${DateTime.now().millisecondsSinceEpoch}',
          paymentMethod: paymentMethod,
        );
        Get.snackbar(
          'Payment Completed',
          'QR matched the active loan and payment was recorded locally.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }

      Get.snackbar('Payment Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // Payment form helpers
  void setPaymentReference(String value) {
    paymentReference.value = value;
  }

  void attachReceipt(String? path) {
    attachedReceiptPath.value = path;
  }

  // Pay Now helpers used by the UI
  void updateReference(String value) {
    paymentReference.value = value;
  }

  void toggleAutoReference(bool value) {
    useAutoReference.value = value;
    if (value) {
      final ocrReference = receiptOcrReferenceNumber.value.trim();
      paymentReference.value = ocrReference;
      paymentReferenceController.text = ocrReference;
    }
  }

  void updatePhoneNumber(String value) {
    if (useAutoPhone.value) {
      final registeredPhone = _userPhoneService.getRegisteredPhone();
      if (registeredPhone.isNotEmpty) {
        phoneNumber.value = registeredPhone;
        return;
      }
    }
    phoneNumber.value = value;
    
  }

  void toggleAutoPhone(bool value) {
    useAutoPhone.value = value;
    if (value) {
      final registeredPhone = _userPhoneService.getRegisteredPhone();
      phoneNumber.value = registeredPhone;
      
    }
  }

  void updateRemarks(String value) {
    remarksValue.value = value;
  }

  void updatePaymentType(String value) {
    selectedPaymentType.value = value;
  }

  Future<void> submitPayNow() async {
    final order = activeLoanOrder;
    if (order == null) {
      Get.snackbar('No active loan', 'Select a loan to pay first.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final paymentType = selectedPaymentType.value.trim();
    if (paymentType.isEmpty) {
      Get.snackbar(
        'Select payment method',
        'Choose how you want to pay before continuing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (paymentType.toLowerCase() == 'cash') {
      final cashPaymentReferenceId = paymentReference.value.trim().isEmpty
          ? 'PAY-${DateTime.now().millisecondsSinceEpoch}'
          : paymentReference.value.trim();
      await recordLoanPaymentSuccess(
        order: order,
        amount: order.remainingAmount,
        paymentReferenceId: cashPaymentReferenceId,
        paymentRequestId: 'pr-local-${DateTime.now().millisecondsSinceEpoch}',
        paymentMethod: paymentType,
      );
      Get.snackbar(
        'Payment recorded',
        'Cash payment was recorded successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
      return;
    }

    final amount = order.remainingAmount;
    final ocrReference = receiptOcrReferenceNumber.value.trim();
    final paymentReferenceId = ocrReference.isNotEmpty
        ? ocrReference
        : paymentReference.value.trim();
    if (ocrReference.isNotEmpty) {
      paymentReference.value = ocrReference;
      paymentReferenceController.text = ocrReference;
      useAutoReference.value = false;
    }

    final success = await processPayment(
      order: order,
      amount: amount,
      paymentReferenceId:
          paymentReferenceId.isEmpty ? null : paymentReferenceId,
      paymentMethod: paymentType,
      receiptPath: attachedReceiptPath.value,
      allowLocalFallback: true,
    );

    if (success) {
      Get.snackbar('Payment recorded', 'Payment was recorded successfully.', snackPosition: SnackPosition.BOTTOM);
      Get.back();
    }
  }

  void payRemainingBalance() {
    final order = activeLoanOrder;
    if (order == null) {
      return;
    }

    recordLoanPaymentSuccess(
      amount: order.remainingAmount,
      order: order,
      paymentReferenceId: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      paymentRequestId: 'pr-local-${DateTime.now().millisecondsSinceEpoch}',
      paymentMethod: selectedPaymentType.value.trim().isEmpty
          ? null
          : selectedPaymentType.value.trim(),
    );
  }

  String _formatAmount(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final decimals = parts[1];

    final buffer = StringBuffer();
    for (int index = 0; index < whole.length; index++) {
      final reverseIndex = whole.length - index;
      buffer.write(whole[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return '${buffer.toString()}.$decimals';
  }

  String get displayUserName {
    final name = currentUserName.value.trim();
    return name.isEmpty ? 'Psosyo User' : name;
  }

  String _safeLogoAsset(String? value) {
    final asset = value?.trim() ?? '';
    if (asset.isEmpty) {
      return 'assets/images/PSosyo-Logo.png';
    }

    final uri = Uri.tryParse(asset);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return asset;
    }

    return asset;
  }

  String? _logoAssetFromMetadata(String? metadataJson) {
    if (metadataJson == null || metadataJson.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(metadataJson);
      if (decoded is Map) {
        final value = decoded['logo_asset']?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    } catch (_) {}

    return null;
  }
}

class TransactionItem {
  const TransactionItem({
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.sign,
    required this.status,
    required this.logoAsset,
  });

  final String title;
  final String dateTime;
  final String amount;
  final String sign;
  final String status;
  final String logoAsset;
}

class _HistoryEntry {
  _HistoryEntry({required this.sortKey, required this.item});

  final DateTime sortKey;
  final TransactionItem item;
}

class _ReceiptOcrResult {
  const _ReceiptOcrResult({this.referenceNumber, this.phoneNumber, this.amount});

  final String? referenceNumber;
  final String? phoneNumber;
  final double? amount;
}

class _ReceiptDetailRow extends StatelessWidget {
  const _ReceiptDetailRow({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E8EF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6D7480),
            ),
          ),
          Flexible(
            child: valueWidget ?? Text(
              value ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2430),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

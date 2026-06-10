import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:p_sosyo/app/data/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/data/models/loan_item_record.dart';
import 'package:p_sosyo/app/data/services/payment_service.dart';
import 'package:p_sosyo/app/data/models/loan_order.dart';
import 'package:p_sosyo/app/data/models/transaction_item.dart';
import 'package:p_sosyo/app/data/services/loan_qr_payload_service.dart';
import 'package:p_sosyo/app/data/services/receipt_ocr_service.dart';
import 'package:p_sosyo/app/data/services/loan_history_service.dart';
import 'package:p_sosyo/app/widgets/loan_agreement_sheet.dart';
import 'package:p_sosyo/app/widgets/loan_details_sheet.dart';
import 'package:p_sosyo/app/widgets/receipt_capture_sheet.dart';
import 'package:p_sosyo/app/widgets/receipt_ocr_dialog.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/pay_now.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/data/services/qr_scanner.dart';
import 'package:p_sosyo/app/data/services/user_phone_service.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  final RxBool showAllBalanceCards = true.obs;
  final RxBool showAllTransactionHistory = false.obs;
  final RxSet<String> _pendingPaymentLoanIds = <String>{}.obs;

  static const double creditLimit = 25000.00;

  final RxDouble _maximumCreditLimitValue = creditLimit.obs;

  final RxList<LoanOrderCard> loanOrders = <LoanOrderCard>[].obs;
  final Rxn<LoanOrderCard> selectedLoanOrder = Rxn<LoanOrderCard>();
  final RxList<TransactionItem> transactionHistory = <TransactionItem>[].obs;
  late final PsosyoDatabaseService _database;
  late final UserPhoneService _userPhoneService;
  final LoanQrPayloadService _loanQrPayloadService =
      const LoanQrPayloadService();
  late final ReceiptOcrService _receiptOcrService;
  late final LoanHistoryService _loanHistoryService;
  late final Future<void> _bootstrapFuture;

  // Payment form state for QR payment page
  final RxString paymentReference = ''.obs;
  final Rxn<String> attachedReceiptPath = Rxn<String>();
  final RxString receiptOcrReferenceNumber = ''.obs;
  final RxString receiptOcrPhoneNumber = ''.obs;
  final RxString receiptOcrAmount = ''.obs;
  final RxString currentUserName = ''.obs;
  final RxBool useAutoReference = true.obs;
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
    _receiptOcrService = Get.find<ReceiptOcrService>();
    _loanHistoryService = LoanHistoryService(
      database: _database,
      formatAmount: _formatAmount,
      formatDate: formatLoanDate,
    );
    _bootstrapFuture = _bootstrapFromDatabase();
    unawaited(_bootstrapCurrentUser());
  }



  Future<void> _bootstrapFromDatabase() async {
    final savedLoans = await _database.loadActiveLoanOrders();
    loanOrders.assignAll(savedLoans);
    final routeSelectedLoanId = _selectedLoanIdFromRoute();
    if (routeSelectedLoanId != null &&
        _selectLoanOrderById(routeSelectedLoanId)) {
      showAllBalanceCards.value = true;
    } else {
      selectedLoanOrder.value = savedLoans.isNotEmpty ? savedLoans.first : null;
    }
    _syncAvailableCredit();

    // Load persisted loan orders and payment requests, then rebuild transaction history.
    final result = await _loanHistoryService.rebuildTransactionHistory();
    transactionHistory.assignAll(result.transactions);
    _pendingPaymentLoanIds
      ..clear()
      ..addAll(result.pendingLoanIds);
  }

  Future<void> _bootstrapCurrentUser() async {
    var registeredPhone = _userPhoneService.getRegisteredPhone();
    if (registeredPhone.isEmpty) {
      registeredPhone = (await _database.loadLatestRegisteredPhone()) ?? '';
      if (registeredPhone.isNotEmpty) {
        _userPhoneService.setRegisteredPhone(registeredPhone);
      }
    }
    final loadedName =
        await _database.loadUserFullName(phoneNumber: registeredPhone);
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
    if (!isPayNowAvailableForLoan(selectedOrder.loanId)) {
      Get.snackbar(
        'Payment pending',
        'This loan has a pending payment request. Wait until it becomes successful before paying again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    selectedLoanOrder.value = selectedOrder;
    Get.to(() => const PayNowPage());
  }

  bool isPayNowAvailableForLoan(String loanId) {
    final key = loanId.trim();
    if (key.isEmpty) {
      return true;
    }
    return !_pendingPaymentLoanIds.contains(key);
  }

  void openQrScannerPage() {
    Get.to(() => const QrScannerPage());
  }

  Future<void> openReceiptCaptureUploadOptions() async {
    await ReceiptCaptureSheet.show(
      onCapturePhoto: () => _attachReceiptFromCamera(),
      onUploadPhoto: () => _attachReceiptFromGallery(),
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
      final recognized = await _receiptOcrService.readReceiptOcr(image.path);
      final reference = recognized.referenceNumber?.trim() ?? '';
      final phoneNumber = recognized.phoneNumber?.trim() ?? '';
      final amount = recognized.amount;

      receiptOcrReferenceNumber.value = reference;
      receiptOcrPhoneNumber.value = phoneNumber;
      receiptOcrAmount.value = amount != null ? _formatAmount(amount) : '';

      if (reference.isEmpty && amount == null) {
        await ReceiptOcrDialog.show(
          Get.context!,
          referenceNumber: null,
          phoneNumber: null,
          amountText: null,
          isSuccess: false,
          remarksValue: remarksValue,
          paymentTypeValue: selectedPaymentType,
          remarksOptions: remarksOptions,
          paymentTypeOptions: paymentTypeOptions,
          onRemarkTap: () => _handleRemarkTap(),
          onPaymentTypeTap: () => _handlePaymentTypeTap(),
          onSubmit: () => submitPayNow(),
          onRetry: () => openReceiptCaptureUploadOptions(),
        );
        return;
      }

      if (reference.isNotEmpty) {
        useAutoReference.value = false;
        paymentReference.value = reference;
      }

      if (phoneNumber.isNotEmpty) {
        this.phoneNumber.value = phoneNumber;
      }

      await ReceiptOcrDialog.show(
        Get.context!,
        referenceNumber: reference.isEmpty ? null : reference,
        phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
        amountText: amount == null ? null : _formatAmount(amount),
        isSuccess: true,
        remarksValue: remarksValue,
        paymentTypeValue: selectedPaymentType,
        remarksOptions: remarksOptions,
        paymentTypeOptions: paymentTypeOptions,
        onRemarkTap: () => _handleRemarkTap(),
        onPaymentTypeTap: () => _handlePaymentTypeTap(),
        onSubmit: () => submitPayNow(),
        onRetry: () => openReceiptCaptureUploadOptions(),
      );
    } catch (e) {
      await ReceiptOcrDialog.show(
        Get.context!,
        referenceNumber: null,
        phoneNumber: null,
        amountText: null,
        isSuccess: false,
        remarksValue: remarksValue,
        paymentTypeValue: selectedPaymentType,
        remarksOptions: remarksOptions,
        paymentTypeOptions: paymentTypeOptions,
        onRemarkTap: () => _handleRemarkTap(),
        onPaymentTypeTap: () => _handlePaymentTypeTap(),
        onSubmit: () => submitPayNow(),
        onRetry: () => openReceiptCaptureUploadOptions(),
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _handleRemarkTap() async {
    final selected = await _showReceiptSelectionMenu(
      title: 'Remarks',
      options: remarksOptions,
    );
    if (selected != null) {
      updateRemarks(selected);
    }
  }

  Future<void> _handlePaymentTypeTap() async {
    final selected = await _showReceiptSelectionMenu(
      title: 'Payment Method',
      options: paymentTypeOptions,
    );
    if (selected != null) {
      updatePaymentType(selected);
    }
  }

  Future<String?> _showReceiptSelectionMenu({
    required String title,
    required List<String> options,
  }) async {
    return showModalBottomSheet<String>(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
              const SizedBox(height: 14),
              for (final option in options) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option),
                  onTap: () => Navigator.of(context).pop(option),
                ),
              ],
            ],
          ),
        );
      },
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

  void toggleTransactionHistoryVisibility() {
    showAllTransactionHistory.toggle();
  }

  Future<bool> importLoanOrderFromQrPayload(String rawPayload) async {
    final userPhone = Get.find<UserPhoneService>().getRegisteredPhone();
    final decodedPayload = _loanQrPayloadService.decodeQrPayload(rawPayload);

    if (decodedPayload != null &&
        _loanQrPayloadService.looksLikeImportableLoanPayload(decodedPayload)) {
      final result = await _database.importLoanOrderPayload(
        decodedPayload,
        userPhone: userPhone,
        rawPayload: rawPayload,
      );

      if (!result.success || result.loanOrder == null) {
        AppSnackbar.error(
          title: 'Loan blocked',
          message:
              result.message ?? 'The scanned QR code could not be imported.',
          position: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
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

    final loanId = _loanQrPayloadService.extractLoanIdFromPayload(
      rawPayload,
      decodedPayload,
    );
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
              final payload =
                  decodedRemote is Map && decodedRemote.containsKey('record')
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
        AppSnackbar.warning(
          title: 'Loan not found',
          message:
              'The scanned QR only contains a loan ID, but that loan is not stored locally yet.',
          position: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
        return false;
      }
    }

    if (decodedPayload != null) {
      AppSnackbar.warning(
        title: 'Unsupported QR',
        message:
            'The scanned QR does not include enough loan details to import or resolve locally.',
        position: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
      return false;
    }

    final result = await _database.importLoanOrderFromRawJson(
      rawPayload,
      userPhone: userPhone,
    );

    if (!result.success || result.loanOrder == null) {
      AppSnackbar.error(
        title: 'Loan blocked',
        message: result.message ?? 'The scanned QR code could not be imported.',
        position: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
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

  Future<bool> submitLoanOrder({
    required LoanPrincipalOption principal,
    required double amount,
    required int termDays,
    DateTime? appliedAt,
    bool seed = false,
  }) async {
    await _bootstrapFuture;
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
      final localPaymentReferenceId =
          paymentReferenceId?.trim().isNotEmpty == true
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
    _pendingPaymentLoanIds.remove(order.loanId.trim());
  }

  Future<void> recordLoanPaymentPending({
    required LoanOrderCard order,
    required double amount,
    String? paymentReferenceId,
    String? paymentRequestId,
    String? paymentMethod,
    DateTime? when,
  }) async {
    final createdAt = when ?? DateTime.now();
    final pendingAmount = amount <= 0 ? order.remainingAmount : amount;
    if (pendingAmount <= 0) {
      return;
    }

    final nowIso = createdAt.toIso8601String();
    final localPaymentRequestId =
        paymentRequestId ?? 'pr-local-${DateTime.now().millisecondsSinceEpoch}';
    final localPaymentReferenceId =
        paymentReferenceId?.trim().isNotEmpty == true
            ? paymentReferenceId!.trim()
            : 'PAY-${DateTime.now().millisecondsSinceEpoch}';
    final selectedMethod = paymentMethod?.trim().isNotEmpty == true
        ? paymentMethod!.trim()
        : selectedPaymentType.value.trim();

    try {
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
        'amount': pendingAmount,
        'status': 'PENDING',
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
        amount: _formatAmount(pendingAmount),
        sign: '+ ',
        status: 'PENDING',
        logoAsset: order.logoAsset,
      ),
    );

    _pendingPaymentLoanIds.add(order.loanId.trim());

    showAllTransactionHistory.value = true;
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
          paymentRequestId: 'pr-local-${DateTime.now().millisecondsSinceEpoch}',
          paymentMethod: paymentMethod,
        );
        return true;
      }

      if (allowLocalFallback) {
        await recordLoanPaymentSuccess(
          order: order,
          amount: amount,
          paymentReferenceId: paymentReferenceId,
          paymentRequestId: 'pr-local-${DateTime.now().millisecondsSinceEpoch}',
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
          paymentRequestId: 'pr-local-${DateTime.now().millisecondsSinceEpoch}',
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
      Get.snackbar('No active loan', 'Select a loan to pay first.',
          snackPosition: SnackPosition.BOTTOM);
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
      showAllTransactionHistory.value = true;
      Get.offAllNamed(AppRoutes.homeScreen);
      return;
    }

    final amount = order.remainingAmount;
    final ocrReference = receiptOcrReferenceNumber.value.trim();
    final paymentReferenceId =
        ocrReference.isNotEmpty ? ocrReference : paymentReference.value.trim();
    if (ocrReference.isNotEmpty) {
      paymentReference.value = ocrReference;
      useAutoReference.value = false;
    }

    await recordLoanPaymentPending(
      order: order,
      amount: amount,
      paymentReferenceId:
          paymentReferenceId.isEmpty ? null : paymentReferenceId,
      paymentMethod: paymentType,
    );

    Get.snackbar(
      'Payment pending',
      'Your payment request was submitted and marked as pending.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.offAllNamed(AppRoutes.homeScreen);
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
}

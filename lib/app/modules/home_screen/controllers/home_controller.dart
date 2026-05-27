import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/services/payment_service.dart';
import 'package:p_sosyo/app/modules/home_screen/models/loan_order.dart';
import 'package:p_sosyo/app/widgets/loan_order_sheet.dart';
import 'package:p_sosyo/app/widgets/loan_agreement_sheet.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/pay_now.dart';

class HomeController extends GetxController {
  final RxBool showAllBalanceCards = true.obs;

  static const double creditLimit = 25000.00;

  final RxDouble _maximumCreditLimitValue = creditLimit.obs;

  final RxList<LoanOrderCard> loanOrders = <LoanOrderCard>[].obs;
  final Rxn<LoanOrderCard> selectedLoanOrder = Rxn<LoanOrderCard>();
  final RxList<TransactionItem> transactionHistory = <TransactionItem>[].obs;

  // Payment form state for QR payment page
  final RxString paymentReference = ''.obs;
  final Rxn<String> attachedReceiptPath = Rxn<String>();

  // Pay Now page state
  final RxBool useAutoReference = true.obs;
  final RxString phoneNumber = ''.obs;
  final RxString remarksValue = ''.obs;
  final RxString selectedPaymentType = ''.obs;
  final TextEditingController payNowReferenceController = TextEditingController();
  final TextEditingController payNowPhoneController = TextEditingController();
  final TextEditingController payNowRemarksController = TextEditingController();

  final List<String> remarksOptions = const [
    'Partial payment',
    'Full payment',
    'Top up',
    'Others',
  ];

  final List<String> paymentTypeOptions = const [
    'Cash',
    'GCash',
    'Bank Transfer',
    'Inventory Financing',
  ];

  final List<LoanPrincipalOption> principalOptions = const [
    LoanPrincipalOption(
      title: 'Nestle',
      logoAsset: 'assets/images/nestle-sample-logo.png',
    ),
    LoanPrincipalOption(
      title: 'Monde Nissin',
      logoAsset: 'assets/images/monde-sample-logo.png',
    ),
    LoanPrincipalOption(
      title: 'Shell',
      logoAsset: 'assets/images/shell-sample-logo.png',
    ),
    LoanPrincipalOption(
      title: 'Nutri Asia',
      logoAsset: 'assets/images/nutriasia-sample-logo.png',
    ),
    LoanPrincipalOption(
      title: 'CDO',
      logoAsset: 'assets/images/cdo-sample-logo.png',
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

    submitLoanOrder(
      principal: principalOptions[1],
      amount: 1574.00,
      appliedAt: DateTime(2026, 4, 28, 10, 23),
      termDays: 6,
      seed: true,
    );

    selectedPaymentType.value = '';
  }

  void openPayNowPage([LoanOrderCard? order]) {
    final selectedOrder = order ?? activeLoanOrder;
    if (selectedOrder == null) {
      return;
    }

    selectedLoanOrder.value = selectedOrder;
    preparePayNowForm();
    Get.to(() => const PayNowPage());
  }

  void preparePayNowForm() {
    useAutoReference.value = true;
    payNowReferenceController.text = loanId;
    payNowPhoneController.clear();
    payNowRemarksController.clear();
    phoneNumber.value = '';
    remarksValue.value = '';
    selectedPaymentType.value = '';
  }

  void toggleAutoReference(bool value) {
    useAutoReference.value = value;
    if (value) {
      payNowReferenceController.text = loanId;
    }
  }

  void updateReference(String value) {
    payNowReferenceController.text = value;
  }

  void updatePhoneNumber(String value) {
    phoneNumber.value = value;
    payNowPhoneController.text = value;
  }

  void updateRemarks(String? value) {
    remarksValue.value = value ?? '';
    payNowRemarksController.text = value ?? '';
  }

  void updatePaymentType(String? value) {
    if (value == null || value.isEmpty) {
      return;
    }

    selectedPaymentType.value = value;
  }

  void submitPayNow() {
    final reference = payNowReferenceController.text.trim();
    final phone = phoneNumber.value.trim();
    final remarks = remarksValue.value.trim();
    final paymentType = selectedPaymentType.value.trim();

    Get.snackbar(
      'Payment ready',
      'Reference $reference prepared for ${paymentType.isEmpty ? 'payment' : paymentType}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );

    paymentReference.value = reference;
    if (phone.isNotEmpty) {
      phoneNumber.value = phone;
    }
    if (remarks.isNotEmpty) {
      remarksValue.value = remarks;
    }
  }

  void openLoanAgreementSheet() {
    Get.bottomSheet(
      const LoanAgreementSheet(),
      isScrollControlled: true,
    );
  }

  void openLoanOrderSheet() {
    Get.bottomSheet(
      const LoanOrderSheet(),
      isScrollControlled: true,
    );
  }

  void toggleBalanceCardsVisibility() {
    showAllBalanceCards.toggle();
  }

  bool importLoanOrderFromQrPayload(String rawPayload) {
    final payload = _decodeQrPayload(rawPayload);
    if (payload == null) {
      Get.snackbar(
        'Invalid QR payload',
        'The scanned QR code does not contain a valid Psosyo loan JSON.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final scannedOrder = _loanOrderFromQrPayload(payload);
    if (scannedOrder == null) {
      Get.snackbar(
        'Invalid QR payload',
        'Missing required loan fields in the scanned QR code.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    _upsertScannedLoanOrder(scannedOrder);
    return true;
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
      final match = RegExp(pattern, multiLine: true, dotAll: true).firstMatch(normalized);
      if (match == null) {
        return null;
      }

      return match.group(1)?.trim();
    }

    payload['loanId'] = matchString(r'"loanId"\s*:\s*"([^"]+)"');
    payload['principalTitle'] = matchString(r'"principalTitle"\s*:\s*"([^"]+)"');
    payload['principalLogo'] = matchString(r'"principalLogo"\s*:\s*"([^"]+)"');
    payload['amountDue'] = matchString(r'"amountDue"\s*:\s*([^,}\n]+)');
    payload['appliedDate'] = matchString(r'"appliedDate"\s*:\s*"([^"]+)"');
    payload['dueDate'] = matchString(r'"dueDate"\s*:\s*"([^"]+)"');

    payload.removeWhere((key, value) => value == null || value.toString().trim().isEmpty);
    return payload;
  }

  LoanOrderCard? _loanOrderFromQrPayload(Map<String, dynamic> payload) {
    final loanId = _findString(payload, ['loanId', 'loan_id', 'id']);
    final principalTitle =
      _findString(payload, ['principalTitle', 'principal_title', 'title']);
    final principalLogo = _resolvePrincipalLogoAsset(principalTitle);
    final amountDue =
      _findAmount(payload, ['amountDue', 'amount_due', 'amount']);
    final appliedDate = _findDate(payload, ['appliedDate', 'applied_date']);
    final dueDate = _findDate(payload, ['dueDate', 'due_date']);

    if (loanId == null ||
        principalTitle == null ||
        principalLogo == null ||
        amountDue == null ||
        appliedDate == null ||
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

  String? _resolvePrincipalLogoAsset(String? principalTitle) {
    if (principalTitle == null || principalTitle.trim().isEmpty) {
      return null;
    }

    final normalizedTitle = _normalizePrincipalTitle(principalTitle);
    for (final option in principalOptions) {
      if (_normalizePrincipalTitle(option.title) == normalizedTitle) {
        return option.logoAsset;
      }
    }

    if (normalizedTitle.contains('monde') || normalizedTitle.contains('nissin')) {
      return 'assets/images/monde-sample-logo.png';
    }
    if (normalizedTitle.contains('nestle')) {
      return 'assets/images/nestle-sample-logo.png';
    }
    if (normalizedTitle.contains('shell')) {
      return 'assets/images/shell-sample-logo.png';
    }
    if (normalizedTitle.contains('nutri') || normalizedTitle.contains('asia')) {
      return 'assets/images/nutriasia-sample-logo.png';
    }
    if (normalizedTitle.contains('cdo')) {
      return 'assets/images/cdo-sample-logo.png';
    }

    return null;
  }

  String _normalizePrincipalTitle(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
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

    final cleaned = value.toString().replaceAll(',', '').replaceAll('₱', '').trim();
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

  void _upsertScannedLoanOrder(LoanOrderCard scannedOrder) {
    final normalizedLoanId = scannedOrder.loanId.toLowerCase().trim();
    final existingIndex = loanOrders.indexWhere(
      (loanOrder) => loanOrder.loanId.toLowerCase().trim() == normalizedLoanId,
    );

    if (existingIndex == -1) {
      loanOrders.insert(0, scannedOrder);
      _maximumCreditLimitValue.value =
          (_maximumCreditLimitValue.value - scannedOrder.remainingAmount)
              .clamp(0, creditLimit)
              .toDouble();
      transactionHistory.insert(
        0,
        TransactionItem(
          title: 'Loan Order',
          dateTime: formatLoanDate(scannedOrder.appliedAt),
          amount: _formatAmount(scannedOrder.originalAmount),
          sign: '- ',
          status: 'SUCCESS',
          logoAsset: scannedOrder.logoAsset,
        ),
      );
    } else {
      final existingOrder = loanOrders[existingIndex];
      final creditDelta =
          scannedOrder.remainingAmount - existingOrder.remainingAmount;
      loanOrders[existingIndex] = scannedOrder;
      _maximumCreditLimitValue.value =
          (_maximumCreditLimitValue.value - creditDelta)
              .clamp(0, creditLimit)
              .toDouble();
      loanOrders.refresh();
    }

    selectedLoanOrder.value = scannedOrder;
  }

  bool submitLoanOrder({
    required LoanPrincipalOption principal,
    required double amount,
    required int termDays,
    DateTime? appliedAt,
    bool seed = false,
  }) {
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

    final loanSequence = loanOrders.length + 1;
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
    _maximumCreditLimitValue.value = (_maximumCreditLimitValue.value - amount)
        .clamp(0, creditLimit)
        .toDouble();

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

  bool submitLoanOrdersByAllocation({
    required Map<LoanPrincipalOption, double> allocations,
    required int termDays,
    DateTime? appliedAt,
  }) {
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
      final success = submitLoanOrder(
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

  void recordLoanPaymentSuccess({
    required LoanOrderCard order,
    required double amount,
    DateTime? when,
  }) {
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

  /// Processes payment through [PaymentService] then records it locally on success.
  Future<bool> processPayment({
    required LoanOrderCard order,
    required double amount,
    String? reference,
    String? receiptPath,
    bool allowLocalFallback = false,
  }) async {
    final service = PaymentService();
    try {
      final success = await service.processPayment(
        loanId: order.loanId,
        amount: amount,
        reference: reference,
        receiptPath: receiptPath,
      );

      if (success) {
        recordLoanPaymentSuccess(order: order, amount: amount);
        return true;
      }

      if (allowLocalFallback) {
        recordLoanPaymentSuccess(order: order, amount: amount);
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
        recordLoanPaymentSuccess(order: order, amount: amount);
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

  @override
  void onClose() {
    payNowReferenceController.dispose();
    payNowPhoneController.dispose();
    payNowRemarksController.dispose();
    super.onClose();
  }

  void payRemainingBalance() {
    final order = activeLoanOrder;
    if (order == null) {
      return;
    }

    recordLoanPaymentSuccess(amount: order.remainingAmount, order: order);
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

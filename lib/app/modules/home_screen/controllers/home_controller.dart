import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:p_sosyo/app/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/database/tables/loan_items_table.dart';
import 'package:p_sosyo/app/services/payment_service.dart';
import 'package:p_sosyo/app/modules/home_screen/models/loan_order.dart';
import 'package:p_sosyo/app/widgets/loan_agreement_sheet.dart';
import 'package:p_sosyo/app/widgets/loan_details_sheet.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/pay_now.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/services/user_phone_service.dart';
import 'package:p_sosyo/app/utils/principal_logo_resolver.dart';

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
  final RxString currentUserName = ''.obs;
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
    unawaited(_bootstrapFromDatabase());
    unawaited(_bootstrapCurrentUser());
    // TextEditingControllers for Pay Now are managed by the PayNowPage widget.
  }

  @override
  void onClose() {
    // UI controllers are disposed by their owning widget.
    super.onClose();
  }

  Future<void> _bootstrapFromDatabase() async {
    final savedLoans = await _database.loadActiveLoanOrders();
    loanOrders.assignAll(savedLoans);
    selectedLoanOrder.value = savedLoans.isNotEmpty ? savedLoans.first : null;
    _syncAvailableCredit();

    // Load persisted loan orders and payment requests, then rebuild transaction history.
    try {
      final loanRows = await _database.loadAllLoanOrders();
      final paymentRows = await _database.loadPaymentRequests(limit: 100);

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
        final logoAsset = _safeLogoAsset(_logoAssetFromMetadata(row['metadata_json']?.toString()));
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
    selectedLoanOrder.value = savedLoans.firstWhere(
      (order) => order.loanId == result.loanOrder!.loanId,
      orElse: () => result.loanOrder!,
    );
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
      final payload = <String, dynamic>{
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'loan_id': order.loanId,
        'amount': paidAmount,
        'logo_asset': order.logoAsset,
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
        await recordLoanPaymentSuccess(order: order, amount: amount);
        return true;
      }

      if (allowLocalFallback) {
        await recordLoanPaymentSuccess(order: order, amount: amount);
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
        await recordLoanPaymentSuccess(order: order, amount: amount);
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
      final generated = 'REF${DateTime.now().millisecondsSinceEpoch % 100000}';
      paymentReference.value = generated;
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
      await recordLoanPaymentSuccess(
        order: order,
        amount: order.remainingAmount,
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
    final reference = paymentReference.value.trim();

    final success = await processPayment(
      order: order,
      amount: amount,
      reference: reference.isEmpty ? null : reference,
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

import 'package:get/get.dart';
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

  String get maximumCreditLimit => _formatAmount(_maximumCreditLimitValue.value);
  double get availableCreditLimitValue => _maximumCreditLimitValue.value;

  LoanOrderCard? get activeLoanOrder =>
      selectedLoanOrder.value ?? (loanOrders.isNotEmpty ? loanOrders.first : null);

  String get remainingBalance =>
      _formatAmount(activeLoanOrder?.remainingAmount ?? 0);

  final String distributorName = 'Fast Sosyo';
  String get principalName => activeLoanOrder?.title ?? 'Nestle';
  String get loanId => activeLoanOrder?.loanId ?? 'AL-001NES';
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
      principal: principalOptions.first,
      amount: 1574.00,
      appliedAt: DateTime(2026, 4, 28, 10, 23),
      termDays: 6,
      seed: true,
    );
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

  void openLoanOrderSheet() {
    Get.bottomSheet(
      const LoanOrderSheet(),
      isScrollControlled: true,
    );
  }

  void toggleBalanceCardsVisibility() {
    showAllBalanceCards.toggle();
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
    _maximumCreditLimitValue.value =
      (_maximumCreditLimitValue.value - amount).clamp(0, creditLimit).toDouble();

    if (!seed) {
      transactionHistory.insert(
        0,
        TransactionItem(
          title: 'Loan Order',
          dateTime: formatLoanDate(createdAt),
          amount: _formatAmount(amount),
          sign: '- ',
          status: 'SUCCESS',
        ),
      );
    }

    return true;
  }

  void recordLoanPaymentSuccess({
    required LoanOrderCard order,
    required double amount,
    DateTime? when,
  }) {
    final createdAt = when ?? DateTime.now();

    final paidAmount = amount > order.remainingAmount
        ? order.remainingAmount
        : amount;
    if (paidAmount <= 0) {
      return;
    }

    order.remainingAmount -= paidAmount;
    _maximumCreditLimitValue.value =
      (_maximumCreditLimitValue.value + paidAmount).clamp(0, creditLimit).toDouble();

    loanOrders.refresh();
    if (selectedLoanOrder.value?.loanId == order.loanId) {
      selectedLoanOrder.refresh();
    }

    transactionHistory.insert(
      0,
      TransactionItem(
        title: 'Loan Payment - ${order.title}',
        dateTime: formatLoanDate(createdAt),
        amount: _formatAmount(paidAmount),
        sign: '+ ',
        status: 'SUCCESS',
      ),
    );
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
  });

  final String title;
  final String dateTime;
  final String amount;
  final String sign;
  final String status;
}

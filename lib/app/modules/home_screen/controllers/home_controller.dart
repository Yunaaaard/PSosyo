import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/loan_agreement_sheet.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/pay_now.dart';

class HomeController extends GetxController {
  final RxBool showAllBalanceCards = true.obs;

  final RxDouble _maximumCreditLimitValue = 25000.00.obs;
  final RxDouble _remainingBalanceValue = 1574.00.obs;

  String get maximumCreditLimit => _formatAmount(_maximumCreditLimitValue.value);
  String get remainingBalance => _formatAmount(_remainingBalanceValue.value);

  final String distributorName = 'Fast Sosyo';
  final String principalName = 'Nestle';
  final String loanId = 'AL - 001NES';
  final String startPaymentDateTime = '04-28-26 | 10:23';
  final String fullyPaidDateTime = '05-04-26 | 10:23';
  final String startingAmount = '370.00';
  final String orderedAmount = '1,834.00';
  final String interestRate = '1%';
  final String processingFee = '2.5%';

  final String repaymentProgress = '8%';
  final double repaymentProgressValue = 0.08;

  final RxList<TransactionItem> transactionHistory = <TransactionItem>[].obs;

  @override
  void onInit() {
    super.onInit();

    recordLoanOrderSuccess(
      amount: 1834.00,
      when: DateTime(2026, 4, 28, 10, 23),
    );
  }

  void openPayNowPage() {
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

  void recordLoanOrderSuccess({required double amount, DateTime? when}) {
    final createdAt = when ?? DateTime.now();

    _maximumCreditLimitValue.value =
        (_maximumCreditLimitValue.value - amount).clamp(0, double.infinity);
    _remainingBalanceValue.value += amount;

    transactionHistory.insert(
      0,
      TransactionItem(
        title: 'Loan Order',
        dateTime: _formatDateLabel('', createdAt),
        amount: _formatAmount(amount),
        status: 'SUCCESS',
      ),
    );
  }

  void recordLoanPaymentSuccess({required double amount, DateTime? when}) {
    final createdAt = when ?? DateTime.now();

    final paidAmount = amount > _remainingBalanceValue.value
        ? _remainingBalanceValue.value
        : amount;
    if (paidAmount <= 0) {
      return;
    }

    _remainingBalanceValue.value -= paidAmount;
    _maximumCreditLimitValue.value += paidAmount;

    transactionHistory.insert(
      0,
      TransactionItem(
        title: 'Loan Payment',
        dateTime: _formatDateLabel('Date Paid', createdAt),
        amount: _formatAmount(paidAmount),
        status: 'SUCCESS',
      ),
    );
  }

  void payRemainingBalance() {
    recordLoanPaymentSuccess(amount: _remainingBalanceValue.value);
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

  String _formatDateLabel(String prefix, DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final year = (value.year % 100).toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final datePart = '$month-$day-$year  |  $hour:$minute';
    if (prefix.trim().isEmpty) {
      return datePart;
    }
    return '$prefix: $datePart';
  }
}

class TransactionItem {
  const TransactionItem({
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.status,
  });

  final String title;
  final String dateTime;
  final String amount;
  final String status;
}

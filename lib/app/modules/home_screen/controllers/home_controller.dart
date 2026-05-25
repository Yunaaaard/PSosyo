import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/loan_agreement_sheet.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/pay_now.dart';

class HomeController extends GetxController {
  final String maximumCreditLimit = '25,000.00';
  final String distributorName = 'Fast Sosyo';
  final String principalName = 'Nestle';
  final String loanId = 'AL - 001NES';
  final String startPaymentDateTime = '04-28-26 | 10:23';
  final String fullyPaidDateTime = '05-04-26 | 10:23';
  final String remainingBalance = '1,574.00';
  final String startingAmount = '370.00';
  final String orderedAmount = '1,834.00';
  final String interestRate = '1%';
  final String processingFee = '2.5%';

  final String repaymentProgress = '8%';
  final double repaymentProgressValue = 0.08;

  final List<TransactionItem> transactionHistory = const [
    TransactionItem(
      title: 'AL - 001NES',
      dateTime: '04-28-26  |  10:23',
      amount: '370.00',
      status: 'SUCCESS',
    ),
    TransactionItem(
      title: 'AL - 001NES',
      dateTime: '04-28-26  |  10:23',
      amount: '370.00',
      status: 'SUCCESS',
    ),
  ];

  void openPayNowPage() {
    Get.to(() => const PayNowPage());
  }

  void openLoanAgreementSheet() {
    Get.bottomSheet(
      const LoanAgreementSheet(),
      isScrollControlled: true,
    );
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/dashed_line.dart';
import 'package:p_sosyo/app/widgets/psosyo_app_bar.dart';
import 'package:p_sosyo/app/widgets/transaction_tile.dart';

class PayNowPage extends GetView<HomeController> {
  const PayNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: const PsosyoAppBar(
        title: 'Loan Agreement Form',
        titleColor: Color(0xFF4B4F57),
        iconColor: Color(0xFFC7CCD4),
        titleFontSize: 20,
        height: 70,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.distributorName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8F949F),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.startPaymentDateTime,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9DA2AC),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            controller.loanId,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8F949F),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.fullyPaidDateTime,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFF4D4F),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const DashedLine(
                    color: Color(0xFFE6E7ED),
                    dashWidth: 9,
                    dashGap: 7,
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Remaining Balance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF959BA7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Obx(
                      () => PesoFormatter.buildPesoText(
                        amount: controller.remainingBalance,
                        fontSize: 35,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6437EC),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Repayment Progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF959BA7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        controller.repaymentProgress,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF6437EC),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: controller.repaymentProgressValue,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFEAE6FB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6437EC),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PesoFormatter.buildPesoText(
                        amount: controller.startingAmount,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8E939E),
                      ),
                      PesoFormatter.buildPesoText(
                        amount: controller.orderedAmount,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8E939E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const DashedLine(
                    color: Color(0xFFE6E7ED),
                    dashWidth: 9,
                    dashGap: 7,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Order Amount',
                    value: controller.orderedAmount,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Interest Rate',
                    value: controller.interestRate,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Processing Fee',
                    value: controller.processingFee,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B4F57),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2F65F4),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int index = 0;
                      index < controller.transactionHistory.length;
                      index++) ...[
                    TransactionTile(
                      title: controller.transactionHistory[index].title,
                      dateTime: controller.transactionHistory[index].dateTime,
                      amount: controller.transactionHistory[index].amount,
                      status: controller.transactionHistory[index].status,
                      compact: true,
                    ),
                    if (index != controller.transactionHistory.length - 1)
                      const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: SizedBox(
          height: 82,
          child: ElevatedButton(
            onPressed: controller.payRemainingBalance,
            style: AppThemes.primaryButtonStyle,
            child: const Text(
              'Pay Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8E939E),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8E939E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

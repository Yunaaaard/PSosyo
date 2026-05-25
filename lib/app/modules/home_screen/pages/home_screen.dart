import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/widgets/dashed_line.dart';
import 'package:p_sosyo/app/widgets/psosyo_app_bar.dart';
import 'package:p_sosyo/app/widgets/transaction_tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: const PsosyoAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A33EA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'MAXIMUM CREDIT LIMIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    PesoFormatter.buildPesoText(
                      amount: controller.maximumCreditLimit,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 26),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0ECFF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pay with Psosyo Credits',
                            style: TextStyle(
                              color: Color(0xFF6B3DF0),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SvgPicture.asset(
                            'assets/icons/scanner.svg',
                            width: 17,
                            height: 17,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF6B3DF0),
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Psosyo Balance',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B4F57),
                ),
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fast Sosyo Nestle',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8D8D95),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '04-28-26  |  10:23',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9D9DA6),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'AL-001NES',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8D8D95),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '05-04-26  |  10:23',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFFF4D4F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const DashedLine(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Repayment Progress',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8C8C94),
                          ),
                        ),
                        Text(
                          controller.repaymentProgress,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B3DF0),
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
                        backgroundColor: const Color(0xFFE8E3FF),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6B3DF0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PesoFormatter.buildPesoText(
                          amount: controller.startingAmount,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8D8D95),
                        ),
                        PesoFormatter.buildPesoText(
                          amount: controller.orderedAmount,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8D8D95),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const DashedLine(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Balance',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1E1E24),
                              ),
                            ),
                            const SizedBox(height: 2),
                            PesoFormatter.buildPesoText(
                              amount: controller.remainingBalance,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6B3DF0),
                            ),
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 200,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B3DF0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: controller.openPayNowPage,
                            child: const Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B4F57),
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2F65F4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Sample tiles for preview
              TransactionTile(
                title: 'Pending Payment',
                dateTime: '05-01-26  |  09:00',
                amount: '300.00',
                status: 'Pending',
                compact: true,
              ),
              const SizedBox(height: 12),
              TransactionTile(
                title: 'Invalid Payment',
                dateTime: '04-20-26  |  08:12',
                amount: '150.00',
                status: 'Invalid',
                compact: true,
              ),
              const SizedBox(height: 16),

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
      ),
    );
  }
}

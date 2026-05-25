import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/dashed_line.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/widgets/psosyo_app_bar.dart';
import 'package:p_sosyo/app/modules/home_screen/pages/pay_now.dart';

class HomeScreen extends StatelessWidget {
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
                      amount: '25,000.00',
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 26),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
                          children: const [
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
                          children: const [
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Repayment Progress',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8C8C94),
                          ),
                        ),
                        Text(
                          '8%',
                          style: TextStyle(
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
                      child: const LinearProgressIndicator(
                        value: 0.08,
                        minHeight: 10,
                        backgroundColor: Color(0xFFE8E3FF),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B3DF0)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PesoFormatter.buildPesoText(
                          amount: '370.00',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8D8D95),
                        ),
                        PesoFormatter.buildPesoText(
                          amount: '1,834.08',
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
                              amount: '1,574.08',
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
                            onPressed: () => Get.to(() => const PayNowPage()),
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
              _TransactionTile(
                title: 'AL-001NES',
                dateTime: '04-28-26  |  10:23',
                amount: '370.00',
                status: 'SUCCESS',
              ),
              const SizedBox(height: 16),
              _TransactionTile(
                title: 'AL-001NES',
                dateTime: '04-28-26  |  10:23',
                amount: '370.00',
                status: 'SUCCESS',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.status,
  });

  final String title;
  final String dateTime;
  final String amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFDDF8E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF19B36B),
              size: 15,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF22222A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateTime,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF9A9AA5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF464955),
                    ),
                  ),
                  PesoFormatter.buildPesoText(
                    amount: amount,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF464955),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF19B36B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
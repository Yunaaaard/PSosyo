import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/widgets/psosyo_app_bar.dart';
import 'package:p_sosyo/app/widgets/transaction_tile.dart';
import 'package:p_sosyo/app/widgets/psosyo_balance_card.dart';
import 'package:p_sosyo/app/services/qr_scanner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

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
                    Obx(
                      () => PesoFormatter.buildPesoText(
                        amount: controller.maximumCreditLimit,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 26),
                    GestureDetector(
                      onTap: () => Get.to(() => const QrScannerPage()),
                      child: Container(
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
                              'Scan QR with Psosyo',
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Obx(() {
                final visibleCards = controller.showAllBalanceCards.value
                    ? controller.loanOrders
                    : controller.loanOrders.take(1).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Psosyo Balance',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4B4F57),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: controller.openLoanOrderSheet,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF2F65F4),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'New Order',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: controller.toggleBalanceCardsVisibility,
                              child: Text(
                                controller.showAllBalanceCards.value
                                    ? 'Hide'
                                    : 'View All',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF2F65F4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final fadeAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          );

                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(0, -0.02),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          key: ValueKey<int>(visibleCards.length),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int index = 0; index < visibleCards.length; index++) ...[
                              PsosyoBalanceCard(
                                title: visibleCards[index].title,
                                loanId: visibleCards[index].loanId,
                                logoAsset: visibleCards[index].logoAsset,
                                appliedDateTime: visibleCards[index].appliedDateTime,
                                dueDateTime: visibleCards[index].dueDateTime,
                                amountDue: visibleCards[index].amountDueText,
                                onPayNow: () => controller.openPayNowPage(
                                  visibleCards[index],
                                ),
                              ),
                              if (index != visibleCards.length - 1)
                                const SizedBox(height: 14),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
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
                        sign: controller.transactionHistory[index].sign,
                        status: controller.transactionHistory[index].status,
                        logoAsset: controller.transactionHistory[index].logoAsset,
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
      ),
    );
  }
}

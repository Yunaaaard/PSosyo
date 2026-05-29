import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/services/app_state_service.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/loan_success_confetti.dart';

class LoanSuccessfulPage extends StatelessWidget {
  const LoanSuccessfulPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoHeight = (constraints.maxHeight * 0.30).clamp(220.0, 320.0);

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: logoHeight,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/loan-success-logo-icon.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Congratulations!\nYou\'re Eligible',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          height: 1.05,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F1F25),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We reviewed your account and you\'re ready to grow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.titleGrey,
                          fontSize: 17,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6F37EF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'MAXIMUM CREDIT LIMIT',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.90),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            PesoFormatter.buildPesoText(
                              amount: '25,000.00',
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.35),
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Expanded(
                                  child: _MetricBlock(
                                    label: 'Service Fee',
                                    value: '1%',
                                    light: true,
                                  ),
                                ),
                                Expanded(
                                  child: _MetricBlock(
                                    label: 'Payment Term',
                                    value: '7 Days',
                                    light: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EEFF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: Color(0xFF6D3DF0),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Secure Banking',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F1F25),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Funds are protected by industry-leading encryption and deposited directly to your digital vault.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.45,
                                      color: Color(0xFF9A9AA5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const Positioned.fill(
                  child: LoanSuccessConfetti(),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppThemes.primaryButtonStyle,
              onPressed: () async {
                await Get.find<AppStateService>().setEligibilityCompleted(true);
                Get.offAllNamed(AppRoutes.homeScreen);
              },
              child: const Text('Continue'),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    required this.light,
  });

  final String label;
  final String value;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.90),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

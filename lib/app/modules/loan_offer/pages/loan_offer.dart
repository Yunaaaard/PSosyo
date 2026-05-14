import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/services/loan_agreement_sheet.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/loan_offer_app_bar.dart';

class LoanOfferPage extends StatelessWidget {
  const LoanOfferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoanOfferAppBar(colors: colors),
                      const SizedBox(height: 28),

                      // ── Credit limit card ──────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
                        decoration: BoxDecoration(
                          color: colors.primaryPurple,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'MAXIMUM CREDIT LIMIT',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            PesoFormatter.buildPesoText(
                              amount: '25,000.00',
                              fontSize: 46,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 18),
                            Container(
                              height: 1.2,
                              color: Colors.white.withOpacity(0.30),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _OfferMetric(
                                    label: 'Service Fee',
                                    value: '1%',
                                    colors: colors,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 54,
                                  color: Colors.white.withOpacity(0.16),
                                ),
                                Expanded(
                                  child: _OfferMetric(
                                    label: 'Payment Term',
                                    value: '7 Days',
                                    colors: colors,
                                    alignRight: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Digital contract section ───────────────────────
                      Text(
                        'DIGITAL CONTRACT',
                        style: TextStyle(
                          color: colors.darkText,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () => Get.bottomSheet(
                          const LoanAgreementSheet(),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          ignoreSafeArea: false,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: colors.lightPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.picture_as_pdf_outlined,
                                  color: colors.primaryPurple,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Loan_Agreement_v2.pdf',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.darkText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to view agreement',
                                      style: TextStyle(
                                        color: colors.titleGrey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colors.titleGrey,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Offer metric chip (used inside the credit limit card) ──────────────────

class _OfferMetric extends StatelessWidget {
  const _OfferMetric({
    required this.label,
    required this.value,
    required this.colors,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final PsosyoThemeColors colors;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final crossAxisAlignment =
        alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.88),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}
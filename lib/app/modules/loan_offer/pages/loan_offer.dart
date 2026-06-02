import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/loan_offer/controllers/loan_offer_controller.dart';
import 'package:p_sosyo/app/core/utils/peso_formatter.dart';
import 'package:p_sosyo/app/core/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/loan_offer_app_bar.dart';

class LoanOfferPage extends StatelessWidget {
  const LoanOfferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoanOfferController>();
    final colors =
        Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

    return Scaffold(
      backgroundColor: colors.surface,

      // ── Sticky bottom bar (warning + button) ────────────────────────────────
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: colors.surface,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFE69C),
                    width: 1,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFFFA500),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please view and sign the agreement to enable E-Sign.',
                        style: TextStyle(
                          color: Color(0xFF856404),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () {
                    final isAgreementAccepted =
                        controller.isAgreementAccepted.value;
                    return ElevatedButton(
                      style: isAgreementAccepted
                          ? AppThemes.primaryButtonStyle
                          : AppThemes.unaccessibleButtonStyle,
                      onPressed:
                          isAgreementAccepted ? controller.openLoanOfferOtp : null,
                      child: const Text('E-Sign via OTP'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────────
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 36),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoanOfferAppBar(colors: colors),
                      const SizedBox(height: 28),

                      // ── Credit limit card ────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
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
                                fontWeight: FontWeight.w500,
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
                                Expanded(
                                  child: _OfferMetric(
                                    label: 'Payment Term',
                                    value: '7 Days',
                                    colors: colors,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Digital contract section ─────────────────────────
                      Text(
                        'DIGITAL CONTRACT',
                        style: TextStyle(
                          color: colors.darkText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 18),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        // File row opens the agreement sheet for terms review.
                        child: GestureDetector(
                          onTap: controller.openAgreementSheet,
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
                                      '1.4MB | Tap to preview agreement',
                                      style: TextStyle(
                                        color: colors.titleGrey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
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

// ── Offer metric chip ──────────────────────────────────────────────────────────

class _OfferMetric extends StatelessWidget {
  const _OfferMetric({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final PsosyoThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}
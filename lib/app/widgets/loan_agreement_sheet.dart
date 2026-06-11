import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_snackbar.dart';
import 'package:p_sosyo/app/data/services/id_verification_service.dart';
import 'package:p_sosyo/app/data/services/loan_agreement_pdf_service.dart';
import 'package:p_sosyo/app/core/themes/theme_colors.dart';
import 'package:p_sosyo/app/core/utils/peso_formatter.dart';

class LoanAgreementSheet extends StatefulWidget {
  const LoanAgreementSheet({super.key, this.onAgreementAccepted});

  final VoidCallback? onAgreementAccepted;

  @override
  State<LoanAgreementSheet> createState() => _LoanAgreementSheetState();
}

class _LoanAgreementSheetState extends State<LoanAgreementSheet> {
  bool _agreedToTerms = false;
  bool _isSavingPdf = false;
  final GlobalKey _signaturePadKey = GlobalKey();
  final List<_SignaturePoint?> _points = <_SignaturePoint?>[];

  bool get _hasSignature => _points.any((point) => point != null);

  Offset? _localPoint(Offset globalPosition) {
    final renderBox =
        _signaturePadKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final localOffset = renderBox.globalToLocal(globalPosition);

    // Check if the point is within the bounds of the signature pad
    if (localOffset.dx < 0 ||
        localOffset.dy < 0 ||
        localOffset.dx > renderBox.size.width ||
        localOffset.dy > renderBox.size.height) {
      return null;
    }

    return localOffset;
  }

  void _clearSignature() {
    setState(() {
      _points.clear();
    });
  }

  Future<void> _submitAgreement() async {
    if (!_agreedToTerms || _isSavingPdf) return;

    setState(() {
      _isSavingPdf = true;
    });

    try {
      final idService =
          Get.isRegistered<IdVerificationService>() ? Get.find<IdVerificationService>() : null;
      final borrowerName = idService?.getScannedName() ?? '';

      final signatureOffsets = _points.map((point) => point?.offset).toList(growable: false);
      final pdfPath = await LoanAgreementPdfService().saveAgreementPdf(
        borrowerName: borrowerName,
        signaturePoints: signatureOffsets,
      );

      widget.onAgreementAccepted?.call();
      if (mounted) Get.back();

      final isAndroid = GetPlatform.isAndroid;
      AppSnackbar.show(
        title: 'Agreement saved',
        message: isAndroid
            ? 'PDF downloaded to your Downloads folder.'
            : 'Agreement PDF saved to: $pdfPath',
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      AppSnackbar.show(
        title: 'Save failed',
        message: 'Unable to generate the agreement PDF right now.',
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6D8DE),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colors.titleGrey,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Loan Agreement Form',
                      style: TextStyle(
                        color: colors.darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PESOPAQ Loan Agreement',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: colors.bodyGrey,
                            fontSize: 18,
                            height: 1.7,
                          ),
                          children: [
                            const TextSpan(
                                text:
                                    'By accepting this Agreement, the Borrower agrees to obtain a loan from Sosyo in the amount of '),
                            TextSpan(
                              children: [
                                PesoFormatter.buildPesoSymbolSpan(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colors.bodyGrey,
                                ),
                                const TextSpan(text: '10,000'),
                              ],
                            ),
                            const TextSpan(
                                text:
                                    ', subject to an interest rate of 5%, with a total payable amount of '),
                            TextSpan(
                              children: [
                                PesoFormatter.buildPesoSymbolSpan(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colors.bodyGrey,
                                ),
                                const TextSpan(text: '10,500'),
                              ],
                            ),
                            const TextSpan(
                                text:
                                    ' due on or before 30 days. The Borrower agrees to fully repay the loan, including any applicable interest and charges, within the agreed period using the available payment methods in the application.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'PESOPAQ Terms and Condition',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '1. Loan Details',
                        style: TextStyle(
                          color: colors.darkText,
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: colors.bodyGrey,
                            fontSize: 18,
                            height: 1.6,
                          ),
                          children: [
                            const TextSpan(text: '• You agree to borrow '),
                            TextSpan(
                              children: [
                                PesoFormatter.buildPesoSymbolSpan(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colors.bodyGrey,
                                ),
                                const TextSpan(text: '10,000'),
                              ],
                            ),
                            const TextSpan(
                                text:
                                    ' with an interest rate of 5%, for a total payable amount of '),
                            TextSpan(
                              children: [
                                PesoFormatter.buildPesoSymbolSpan(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colors.bodyGrey,
                                ),
                                const TextSpan(text: '10,500'),
                              ],
                            ),
                            const TextSpan(text: ', due on or before 30 days.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Signature',
                        style: TextStyle(
                          color: colors.darkText,
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // FIX: Corrected parenthesis nesting for GestureDetector > Container > CustomPaint > Stack
                      GestureDetector(
                        onPanStart: (details) {
                          final localPoint =
                              _localPoint(details.globalPosition);
                          if (localPoint == null) return;
                          setState(() {
                            _points.add(_SignaturePoint(localPoint));
                          });
                        },
                        onPanUpdate: (details) {
                          final localPoint =
                              _localPoint(details.globalPosition);
                          if (localPoint == null) return;
                          setState(() {
                            _points.add(_SignaturePoint(localPoint));
                          });
                        },
                        onPanEnd: (_) {
                          setState(() {
                            _points.add(null);
                          });
                        },
                        child: Container(
                          key: _signaturePadKey,
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: CustomPaint(
                            painter: _DashedBorderPainter(
                              color: const Color(0xFFC8CBD3),
                              width: 1.4,
                              borderRadius: 18,
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter:
                                        _SignaturePainter(points: _points),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 22),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 32),
                                          child: Container(
                                            width: double.infinity,
                                            height: 1.2,
                                            color: const Color(0xFFBDC2CC),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Signature',
                                          style: TextStyle(
                                            color: colors.darkText,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400,
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
                      ),

                      const SizedBox(height: 18),
                      // FIX: Disable clear button when there's nothing to clear
                      TextButton(
                        onPressed: _hasSignature ? _clearSignature : null,
                        child: const Text('Clear Signature'),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _agreedToTerms
                                    ? const Color(0xFF3C73FF)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF3C73FF),
                                  width: 1.6,
                                ),
                              ),
                              child: _agreedToTerms
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: colors.bodyGrey,
                                    fontSize: 18,
                                    height: 1.35,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: 'I have read and agree to the '),
                                    const TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: Color(0xFF2F6CFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(text: ' and the '),
                                    const TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xFF2F6CFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(
                                        text: ' for this digital loan.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: _agreedToTerms
                              ? AppThemes.primaryButtonStyle
                              : AppThemes.unaccessibleButtonStyle,
                          onPressed: _agreedToTerms
                              ? _submitAgreement
                              : null,
                          child: _isSavingPdf
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Done'),
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
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.width,
    required this.borderRadius,
  });

  final Color color;
  final double width;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final extractPath =
            metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.width != width ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class _SignaturePoint {
  _SignaturePoint(this.offset);

  final Offset offset;
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({required this.points});

  final List<_SignaturePoint?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2F333A)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < points.length - 1; index++) {
      final currentPoint = points[index];
      final nextPoint = points[index + 1];

      if (currentPoint != null && nextPoint != null) {
        canvas.drawLine(currentPoint.offset, nextPoint.offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

class LoanAgreementSheet extends StatefulWidget {
  const LoanAgreementSheet({super.key});

  @override
  State<LoanAgreementSheet> createState() => _LoanAgreementSheetState();
}

class _LoanAgreementSheetState extends State<LoanAgreementSheet> {
  bool _agreedToTerms = false;
  final GlobalKey _signaturePadKey = GlobalKey();
  final List<_SignaturePoint?> _points = <_SignaturePoint?>[];

  bool get _hasSignature => _points.any((point) => point != null);

  Offset? _localPoint(Offset globalPosition) {
    final renderBox = _signaturePadKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return null;
    }

    return renderBox.globalToLocal(globalPosition);
  }

  void _clearSignature() {
    setState(() {
      _points.clear();
    });
  }

  void _submitAgreement() {
    if (!_agreedToTerms || !_hasSignature) {
      return;
    }

    Get.back();
    Get.snackbar(
      'Agreement saved',
      'Your signature has been captured for review.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

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
                        'Psosyo Loan Agreement',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'By accepting this Agreement, the Borrower agrees to obtain a loan from Sosyo in the amount of ₱[Amount], subject to an interest rate of [x%], with a total payable amount of ₱[Total Amount] due on or before [Due Date]. The Borrower agrees to fully repay the loan, including any applicable interest and charges, within the agreed period using the available payment methods in the application.',
                        style: TextStyle(
                          color: colors.bodyGrey,
                          fontSize: 18,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Psosyo Terms and Condition',
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
                      Text(
                        '• You agree to borrow ₱[Amount] with an interest rate of [x%], for a total payable amount of ₱[Total Amount], due on or before [Due Date].',
                        style: TextStyle(
                          color: colors.bodyGrey,
                          fontSize: 18,
                          height: 1.6,
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
                      GestureDetector(
                        onPanStart: (details) {
                          final localPoint = _localPoint(details.globalPosition);
                          if (localPoint == null) {
                            return;
                          }
                          setState(() {
                            _points.add(_SignaturePoint(localPoint));
                          });
                        },
                        onPanUpdate: (details) {
                          final localPoint = _localPoint(details.globalPosition);
                          if (localPoint == null) {
                            return;
                          }
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
                          height: 170,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFC8CBD3), width: 1.4),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _SignaturePainter(points: _points),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 22),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 82,
                                        height: 1.2,
                                        color: const Color(0xFFBDC2CC),
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
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: _clearSignature,
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
                                color: _agreedToTerms ? const Color(0xFF3C73FF) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF3C73FF),
                                  width: 1.6,
                                ),
                              ),
                              child: _agreedToTerms
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
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
                                    const TextSpan(text: 'I have read and agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: const TextStyle(
                                        color: Color(0xFF2F6CFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(text: '\nand the '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        color: Color(0xFF2F6CFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(text: ' for this digital loan.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: (_agreedToTerms && _hasSignature)
                              ? AppThemes.primaryButtonStyle
                              : AppThemes.unaccessibleButtonStyle,
                          onPressed: (_agreedToTerms && _hasSignature) ? _submitAgreement : null,
                          child: const Text('Done'),
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
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return true;
  }
}

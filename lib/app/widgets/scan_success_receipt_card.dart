import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:p_sosyo/app/core/utils/peso_formatter.dart';
import 'package:p_sosyo/app/widgets/scan_success_receipt_info_row.dart';

class ScanSuccessReceiptCard extends StatelessWidget {
  const ScanSuccessReceiptCard({
    required this.qrData,
    required this.from,
    required this.to,
    required this.referenceId,
    required this.formattedDateTime,
    required this.amountSent,
    this.paymentReference,
    super.key,
  });

  final String qrData;
  final String from;
  final String to;
  final String referenceId;
  final String formattedDateTime;
  final String amountSent;
  final String? paymentReference;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth * 0.96).clamp(320.0, 520.0).toDouble();
        final double cardHeight = cardWidth * 1.86;
        final double scale = (cardWidth / 320).clamp(0.95, 1.32).toDouble();

        return SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/icons/Succes_reciept_template.svg',
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18 * scale, 40 * scale, 18 * scale, 18 * scale),
                child: Column(
                  children: [
                    Text(
                      'Payment Successful',
                      style: TextStyle(
                        color: const Color(0xFF171B22),
                        fontSize: 25 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Show this QR code to the salesman to verify your payment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF8A8D91),
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 25 * scale),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showEnlargedQr(context, scale),
                        child: Hero(
                          tag: 'receipt_qr_$referenceId',
                          child: SizedBox(
                            width: 210 * scale,
                            height: 210 * scale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                QrImageView(
                                  data: qrData,
                                  size: 210 * scale,
                                  backgroundColor: Colors.white,
                                  version: QrVersions.auto,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                  gapless: true,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.circle,
                                    color: Color(0xFF171B22),
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.circle,
                                    color: Color(0xFF171B22),
                                  ),
                                ),
                                Container(
                                  width: 32 * scale,
                                  height: 32 * scale,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E5DC8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5 * scale,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16 * scale,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 55 * scale),
                    ScanSuccessReceiptInfoRow(label: 'From:', value: from, scale: scale),
                    SizedBox(height: 14 * scale),
                    ScanSuccessReceiptInfoRow(label: 'To:', value: to, scale: scale),
                    SizedBox(height: 12 * scale),
                    ScanSuccessReceiptInfoRow(
                      label: 'Reference ID:',
                      value: (paymentReference != null && paymentReference!.isNotEmpty)
                          ? paymentReference!
                          : referenceId,
                      scale: scale,
                    ),
                    SizedBox(height: 12 * scale),
                    ScanSuccessReceiptInfoRow(label: 'Date:', value: formattedDateTime, scale: scale),
                    SizedBox(height: 18 * scale),
                    const Divider(
                      color: Color(0xFF333333),
                      thickness: 1,
                      height: 1,
                    ),
                    SizedBox(height: 18 * scale),
                    Text(
                      'Amount Sent',
                      style: TextStyle(
                        color: const Color(0xFF8F9398),
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\u20B1 ',
                              style: TextStyle(
                                color: const Color(0xFF2E5DC8),
                                fontSize: 32 * scale,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                            TextSpan(
                              text: amountSent,
                              style: TextStyle(
                                color: const Color(0xFF2E5DC8),
                                fontSize: 28 * scale,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEnlargedQr(BuildContext context, double scale) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Enlarged QR Code',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final double modalWidth = (MediaQuery.of(context).size.width * 0.94).clamp(320.0, 500.0);
        final String displayRef = (paymentReference != null && paymentReference!.isNotEmpty)
            ? paymentReference!
            : referenceId;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: modalWidth,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment QR Code',
                          style: TextStyle(
                            color: Color(0xFF171B22),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          color: const Color(0xFF8A8D91),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Hero(
                      tag: 'receipt_qr_$referenceId',
                      child: SizedBox(
                        width: modalWidth - 32,
                        height: modalWidth - 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            QrImageView(
                              data: qrData,
                              size: modalWidth - 32,
                              backgroundColor: Colors.white,
                              version: QrVersions.auto,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                              gapless: true,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.circle,
                                color: Color(0xFF171B22),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.circle,
                                color: Color(0xFF171B22),
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E5DC8),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E8EF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'To',
                                style: TextStyle(
                                  color: Color(0xFF8A8D91),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                to,
                                style: const TextStyle(
                                  color: Color(0xFF171B22),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ref ID',
                                style: TextStyle(
                                  color: Color(0xFF8A8D91),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                displayRef,
                                style: const TextStyle(
                                  color: Color(0xFF171B22),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Amount',
                                style: TextStyle(
                                  color: Color(0xFF8A8D91),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              PesoFormatter.buildPesoText(
                                amount: amountSent,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2E5DC8),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

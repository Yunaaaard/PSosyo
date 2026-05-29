import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:p_sosyo/app/widgets/scan_success_receipt_info_row.dart';

class ScanSuccessReceiptCard extends StatelessWidget {
  const ScanSuccessReceiptCard({
    required this.qrData,
    required this.from,
    required this.to,
    required this.referenceNo,
    required this.formattedDateTime,
    required this.amountSent,
    super.key,
  });

  final String qrData;
  final String from;
  final String to;
  final String referenceNo;
  final String formattedDateTime;
  final String amountSent;

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
                    SizedBox(height: 18 * scale),
                    SizedBox(
                      width: 174 * scale,
                      height: 174 * scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          QrImageView(
                            data: qrData,
                            size: 158 * scale,
                            backgroundColor: Colors.white,
                            version: QrVersions.auto,
                            gapless: true,
                          ),
                          Container(
                            width: 44 * scale,
                            height: 44 * scale,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E5DC8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3 * scale,
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
                                size: 24 * scale,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 34 * scale),
                    ScanSuccessReceiptInfoRow(label: 'From:', value: from, scale: scale),
                    SizedBox(height: 14 * scale),
                    ScanSuccessReceiptInfoRow(label: 'To:', value: to, scale: scale),
                    SizedBox(height: 12 * scale),
                    ScanSuccessReceiptInfoRow(label: 'Ref No:', value: referenceNo, scale: scale),
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
}
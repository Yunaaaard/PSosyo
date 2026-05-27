import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

class PaymentReceiptData {
  const PaymentReceiptData({
    required this.customerName,
    required this.distributor,
    required this.referenceNumber,
    required this.dateLabel,
    required this.amount,
  });

  final String customerName;
  final String distributor;
  final String referenceNumber;
  final String dateLabel;
  final double amount;
}

class SuccessPaymentPage extends StatelessWidget {
  const SuccessPaymentPage({super.key, required this.receipt});

  final PaymentReceiptData receipt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9BC8F4),
      body: SafeArea(
        child: Stack(
          children: [
            const _SuccessBackground(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 640),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 36),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Payment Successful',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF14181D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 34),
                          child: Text(
                            'Show this receipt to the salesman to verify your payment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.45,
                              color: Color(0xFF5D6470),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3FF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFBFD0E8),
                              width: 8,
                            ),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 54,
                            color: Color(0xFF2F66E5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              _DetailRow(label: 'From:', value: receipt.customerName),
                              const SizedBox(height: 18),
                              _DetailRow(label: 'To:', value: receipt.distributor),
                              const SizedBox(height: 18),
                              _DetailRow(label: 'Ref No:', value: receipt.referenceNumber),
                              const SizedBox(height: 18),
                              _DetailRow(label: 'Date:', value: receipt.dateLabel),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Amount Sent',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFFA3A6AE),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: PesoFormatter.buildPesoText(
                            amount: _formatAmount(receipt.amount),
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: AppColors.psosyo.accentBlue,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed(AppRoutes.homeScreen),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F66E5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            child: const Text('Back to Home'),
          ),
        ),
      ),
    );
  }
}

class _SuccessBackground extends StatelessWidget {
  const _SuccessBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8FC1F2),
            Color(0xFF9BC8F4),
            Color(0xFF88A5F8),
          ],
          stops: [0.0, 0.56, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -35,
            child: _BlurOrb(size: 180, color: Color(0xFFBFD5FF).withOpacity(0.42)),
          ),
          Positioned(
            top: 260,
            left: -70,
            child: _BlurOrb(size: 180, color: Color(0xFFDFE7FF).withOpacity(0.34)),
          ),
          Positioned(
            bottom: 140,
            right: -60,
            child: _BlurOrb(size: 170, color: Color(0xFFB8D5FF).withOpacity(0.35)),
          ),
          Positioned(
            bottom: 40,
            left: -50,
            child: _BlurOrb(size: 160, color: Color(0xFF8BC0F5).withOpacity(0.28)),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TicketDividerPainter(),
      child: const SizedBox(height: 42, width: double.infinity),
    );
  }
}

class _TicketDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9FC1F4)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    canvas.drawLine(
      const Offset(16, 0),
      Offset(size.width - 16, 0),
      paint,
    );
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF999DA4),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF5B5F66),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatAmount(double amount) {
  final whole = amount.toStringAsFixed(2);
  final parts = whole.split('.');
  final integer = parts.first;
  final decimals = parts.last;
  final reversed = integer.split('').reversed.toList();
  final buffer = StringBuffer();

  for (var index = 0; index < reversed.length; index++) {
    if (index != 0 && index % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(reversed[index]);
  }

  final formattedInteger = buffer.toString().split('').reversed.join();
  return '$formattedInteger.$decimals';
}

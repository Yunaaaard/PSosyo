import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/scan_success_controller.dart';
import 'package:p_sosyo/app/widgets/scan_success_receipt_card.dart';

class ScanSuccessPage extends GetView<ScanSuccessController> {
  const ScanSuccessPage({super.key});

  static const Color _primaryBlue = Color(0xFF6B3DF0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/scan_bg.png',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double horizontalPadding = constraints.maxWidth * 0.06;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Obx(
                            () => SingleChildScrollView(
                              child: ScanSuccessReceiptCard(
                                qrData: controller.enrichedQrData,
                                from: controller.senderName.value,
                                to: controller.recipientName,
                                referenceId: controller.displayReferenceId,
                                formattedDateTime: controller.formattedDateTime,
                                amountSent: controller.formatMoney(controller.amountDueFromQr),
                                paymentReference: controller.paymentReference,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: controller.goHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Back to Home',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

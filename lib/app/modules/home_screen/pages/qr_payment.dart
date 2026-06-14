import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/about_yourself_controller.dart';
import 'package:p_sosyo/app/data/services/id_verification_service.dart';
import 'package:p_sosyo/app/core/utils/peso_formatter.dart';
import 'package:p_sosyo/app/core/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/psosyo_app_bar.dart';
import 'package:p_sosyo/app/widgets/dashed_line.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPaymentPage extends StatelessWidget {
  const QrPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: const PsosyoAppBar(
        title: 'Paqner Pay',
        titleColor: Color(0xFF4B4F57),
        iconColor: Color(0xFFC7CCD4),
        titleFontSize: 20,
        height: 70,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: _buildNameWidget(),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Scan this qr code to repay your loan',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9EA3AA),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Obx(() {
                        final payload = jsonEncode({
                          'type': 'paqner_payment_test',
                          'referenceId': controller.referenceId,
                          'amount': controller.orderedAmount,
                          'name': _firstNameOnly(_currentName()),
                        });

                        return QrImageView(
                          data: payload,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Test QR: ${controller.referenceId}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8F949F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const DashedLine(
                    color: Color(0xFFE6E7ED),
                    dashWidth: 9,
                    dashGap: 7,
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Remaining Balance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF959BA7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Obx(
                      () => PesoFormatter.buildPesoText(
                        amount: controller.remainingBalance,
                        fontSize: 35,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6437EC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Reference Number',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2F333A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: controller.setPaymentReference,
              decoration: InputDecoration(
                hintText: 'Input Text',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE6E7ED)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE6E7ED)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Upload box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6E7ED)),
              ),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Placeholder: actual file picker should be implemented in controller/service
                      controller.attachReceipt('mock/path/receipt.png');
                    },
                    icon: const Icon(Icons.upload_file, color: Color(0xFF9DA2AC)),
                    label: const Text(
                      'Upload',
                      style: TextStyle(
                        color: Color(0xFF9DA2AC),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Attach payment reciept. PNG, JPG or PDF up to 10MB',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9EA3AA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: SizedBox(
          height: 68,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: AppThemes.primaryButtonStyle,
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildNameWidget() {
  // Prefer AboutYourselfController fullname if available
  if (Get.isRegistered<AboutYourselfController>()) {
    return GetBuilder<AboutYourselfController>(
      builder: (c) {
        final text = _firstNameOnly(c.fullnameController.text);
        return Text(
          text.isNotEmpty ? 'Hello, $text' : 'Hello, User',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2F333A),
          ),
        );
      },
    );
  }

  // Otherwise fall back to IdVerificationService scanned name if present
  if (Get.isRegistered<IdVerificationService>()) {
    final idService = Get.find<IdVerificationService>();
    return Obx(() {
      final scanned = _firstNameOnly(idService.scannedName.value ?? '');
      return Text(
        scanned.isNotEmpty ? 'Hello, $scanned' : 'Hello, User',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2F333A),
        ),
      );
    });
  }

  // Fallback to a generic greeting
  return const Text(
    'Hello, User',
    style: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: Color(0xFF2F333A),
    ),
  );
}

String _firstNameOnly(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  return trimmed.split(RegExp(r'\s+')).first;
}

String _currentName() {
  if (Get.isRegistered<AboutYourselfController>()) {
    return Get.find<AboutYourselfController>().fullnameController.text;
  }

  if (Get.isRegistered<IdVerificationService>()) {
    return Get.find<IdVerificationService>().scannedName.value ?? '';
  }

  return '';
}

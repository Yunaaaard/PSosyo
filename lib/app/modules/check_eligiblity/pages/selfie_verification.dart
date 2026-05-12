import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/selfie_verification_controller.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/basic_info_appbar.dart';

class SelfieVerificationPage extends StatelessWidget {
  const SelfieVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {

      return GetBuilder<SelfieVerificationController>(
        builder: (controller) {
          final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

          return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BasicInfoAppBar(),
              const SizedBox(height: 24),
              Text(
                'Step 2 of 4',
                style: TextStyle(
                  color: colors.darkText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(height: 13, color: const Color(0xFFE9E3FF)),
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(height: 13, color: colors.primaryPurple),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Selfie Verification',
                style: TextStyle(
                  color: colors.darkText,
                  fontSize: 25,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'Ensure you are in a well-lit area and not wearing a hat or glass.',
                style: TextStyle(
                  color: colors.titleGrey,
                  fontSize: 18,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Expanded(
                child: Center(
                  child: Obx(() {
                    final started = controller.isLivenessCheckStarted.value;
                    final capturing = controller.isCapturing.value;
                    final hasCapture = controller.selfieFile.value != null;

                    return DottedBorder(
                      color: colors.primaryPurple,
                      strokeWidth: 2,
                      dashPattern: const [8, 6],
                      borderType: BorderType.Circle,
                      radius: const Radius.circular(180),
                      child: Container(
                        width: 350,
                        height: 350,
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: ClipOval(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: controller.startLivenessCheck,
                              child: SizedBox(
                                width: 350,
                                height: 350,

                                // ── State: photo captured ──────────
                                child: hasCapture
                                    ? Image.file(
                                        File(controller.selfieFile.value!.path),
                                        fit: BoxFit.cover,
                                      )
                                    // ── State: liveness started ─
                                    : started
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              capturing
                                                  ? const SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 3,
                                                        color: Color(0xFF2563EB),
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.camera_alt_outlined,
                                                      size: 40,
                                                      color: Color(0xFF2563EB),
                                                    ),
                                              const SizedBox(height: 16),
                                              Text(
                                                capturing
                                                    ? 'Opening Camera...'
                                                    : 'Tap to Capture',
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 20,
                                                  color: Color(0xFF222222),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'Position your face within the frame',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Color(0xFF8B8B8B),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          )
                                        // ── State: idle ────────────
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                size: 60,
                                                color: colors.primaryPurple,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Start Liveness Check',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20,
                                                  color: colors.darkText,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Position your face within the frame',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: colors.titleGrey,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () {
                  final hasCapture = controller.selfieFile.value != null;
                  return ElevatedButton(
                    style: hasCapture
                        ? AppThemes.primaryButtonStyle
                        : AppThemes.unaccessibleButtonStyle,
                    onPressed: hasCapture
                        ? () => Get.toNamed(AppRoutes.aboutYourself)
                        : null,
                    child: const Text('Continue'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
        },
      );
  }
}
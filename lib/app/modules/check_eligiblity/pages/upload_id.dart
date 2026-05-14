import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/upload_id_controller.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/basic_info_appbar.dart';

class UploadIdPage extends StatelessWidget {
  const UploadIdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UploadIdController>(
      builder: (controller) {
        final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

        return Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BasicInfoAppBar(),
                    const SizedBox(height: 24),
                    Text(
                      'Step 1 of 4',
                      style: TextStyle(
                        color: colors.darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        children: [
                          Container(height: 13, color: const Color(0xFFE9E3FF)),
                          FractionallySizedBox(
                            widthFactor: 0.25,
                            child: Container(height: 13, color: colors.primaryPurple),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Upload your Government ID',
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
                      'Please take a clear photo of your government-issued ID card. Ensure all details are legible and within the frame.',
                      style: TextStyle(
                        color: colors.titleGrey,
                        fontSize: 18,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select ID Type',
                      style: TextStyle(
                        color: colors.darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ID type dropdown
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE3E5EA), width: 1.2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Obx(
                          () => DropdownButton<String>(
                            isExpanded: true,
                            value: controller.selectedIdType.value,
                            hint: Text(
                              'Select Id type here',
                              style: TextStyle(
                                color: colors.titleGrey,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            items: controller.idOptions
                                .map((o) => DropdownMenuItem(
                                      value: o,
                                      child: Text(
                                        o,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins', fontSize: 18),
                                      ),
                                    ))
                                .toList(),
                            onChanged: controller.setSelectedIdType,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: colors.titleGrey,
                              size: 30,
                            ),
                            style: TextStyle(
                              color: colors.darkText,
                              fontSize: 18,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Upload boxes — shown only when an ID type is selected
                    Obx(
                      () => controller.selectedIdType.value != null
                          ? Column(
                              children: [
                                // ── Front orientation warning ──────────────
                                Obx(() {
                                  if (controller.orientationWarning.value == null ||
                                      controller.orientationWarning.value!.isEmpty) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.rotate_90_degrees_ccw_rounded,
                                              color: Color(0xFFA16207), size: 24),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              controller.orientationWarning.value!,
                                              style: const TextStyle(
                                                color: Color(0xFFA16207),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                // ── Front upload box ───────────────────────
                                DottedBorder(
                                  color: colors.primaryPurple,
                                  strokeWidth: 2,
                                  dashPattern: const [8, 6],
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(16),
                                  child: GestureDetector(
                                    onTap: () => controller.pickImage(true),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 180,
                                      child: Obx(
                                        () => controller.frontImage.value == null
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.camera_alt_outlined,
                                                      color: colors.primaryPurple, size: 36),
                                                  const SizedBox(height: 8),
                                                  Text('Front of ID',
                                                      style: TextStyle(
                                                          color: colors.darkText,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 18)),
                                                  const SizedBox(height: 6),
                                                  Text('PNG, JPG or PDF up to 10MB',
                                                      style: TextStyle(color: colors.titleGrey)),
                                                ],
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.file(
                                                    File(controller.frontImage.value!.path),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ── Back orientation warning ───────────────
                                Obx(() {
                                  if (controller.backOrientationWarning.value == null ||
                                      controller.backOrientationWarning.value!.isEmpty) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.qr_code_2_rounded,
                                              color: Color(0xFFA16207), size: 24),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              controller.backOrientationWarning.value!,
                                              style: const TextStyle(
                                                color: Color(0xFFA16207),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                // ── Back upload box ────────────────────────
                                DottedBorder(
                                  color: colors.primaryPurple,
                                  strokeWidth: 2,
                                  dashPattern: const [8, 6],
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(16),
                                  child: GestureDetector(
                                    onTap: () => controller.pickImage(false),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 180,
                                      child: Obx(
                                        () => controller.backImage.value == null
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.camera_alt_outlined,
                                                      color: colors.primaryPurple, size: 36),
                                                  const SizedBox(height: 8),
                                                  Text('Back of ID',
                                                      style: TextStyle(
                                                          color: colors.darkText,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 18)),
                                                  const SizedBox(height: 6),
                                                  Text('Keep the barcode and text visible',
                                                      style: TextStyle(color: colors.titleGrey)),
                                                ],
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.file(
                                                    File(controller.backImage.value!.path),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ),

                    // ── Single unified status card (above Continue) ────────
                    const SizedBox(height: 24),
                    Obx(() {
                      final isScanning = controller.isScanning.value;
                      final scanWarning = controller.scanWarning.value;
                      final qrWarning = controller.qrScanWarning.value;
                      final frontName = controller.scannedName.value;
                      final qrName = controller.scannedQrName.value;
                      final qrCode = controller.scannedQrCode.value;
                      final namesMatch = controller.nameMatchResult.value;

                      // 1. Scanning in progress
                      if (isScanning) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF7C3AED)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  (frontName != null && frontName.isNotEmpty)
                                      ? 'Scanning QR code...'
                                      : 'Scanning ID information...',
                                  style: TextStyle(
                                      color: colors.darkText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 2. Any scan error
                      final warning = (scanWarning != null && scanWarning.isNotEmpty)
                          ? scanWarning
                          : (qrWarning != null && qrWarning.isNotEmpty)
                              ? qrWarning
                              : null;
                      if (warning != null) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFFB91C1C), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(warning,
                                    style: const TextStyle(
                                        color: Color(0xFFB91C1C),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      }

                      // 3. QR verified — final state
                      if (qrName != null && qrName.isNotEmpty) {
                        final isMatch = namesMatch == true;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isMatch
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isMatch ? Icons.verified_rounded : Icons.info_rounded,
                                color: isMatch
                                    ? colors.primaryPurple
                                    : const Color(0xFFA16207),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isMatch ? 'Name Verified' : 'Name Mismatch',
                                      style: TextStyle(
                                          color: colors.darkText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isMatch
                                          ? qrName
                                          : 'QR name doesn\'t match front ID. Please verify.',
                                      style: TextStyle(
                                          color: colors.darkText,
                                          fontSize: 16,
                                          fontWeight: isMatch
                                              ? FontWeight.w700
                                              : FontWeight.w400),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 4. QR found but unrecognized
                      if (qrCode != null && qrCode.isNotEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.qr_code_2_rounded,
                                  color: Color(0xFFA16207), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'QR code found but format not recognized.',
                                  style: TextStyle(
                                      color: colors.titleGrey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 5. Front name detected, waiting for back
                      if (frontName != null && frontName.isNotEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: colors.primaryPurple, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name detected',
                                      style: TextStyle(
                                          color: colors.darkText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      frontName,
                                      style: TextStyle(
                                          color: colors.darkText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Now upload the back of your ID to verify.',
                                      style: TextStyle(
                                          color: colors.titleGrey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox();
                    }),

                    // ── Continue button ────────────────────────────────────
                    const SizedBox(height: 16),
                    Obx(() {
                      final bothImagesSelected = controller.frontImage.value != null &&
                          controller.backImage.value != null;
                      final idType = (controller.selectedIdType.value ?? '').toLowerCase();
                      final isDriver = idType.contains('driver');
                      final namesMatch = controller.nameMatchResult.value ?? false;
                      final canContinue = bothImagesSelected && (isDriver || namesMatch);
                      return ElevatedButton(
                        style: canContinue
                            ? AppThemes.primaryButtonStyle
                            : AppThemes.unaccessibleButtonStyle,
                        onPressed: canContinue
                            ? () => Get.toNamed(AppRoutes.selfieVerification)
                            : null,
                        child: const Center(child: Text('Continue')),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
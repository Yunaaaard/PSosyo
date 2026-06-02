import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/core/themes/theme_colors.dart';

class ReceiptCaptureSheet extends StatelessWidget {
  const ReceiptCaptureSheet({
    super.key,
    required this.onCapturePhoto,
    required this.onUploadPhoto,
  });

  final VoidCallback onCapturePhoto;
  final VoidCallback onUploadPhoto;

  static Future<void> show({
    required VoidCallback onCapturePhoto,
    required VoidCallback onUploadPhoto,
  }) {
    return Get.bottomSheet(
      ReceiptCaptureSheet(
        onCapturePhoto: onCapturePhoto,
        onUploadPhoto: onUploadPhoto,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE3E6EE),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Attach E-receipt Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F333A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture a new photo or upload one from your gallery.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7C828E),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  onCapturePhoto();
                },
                style: AppThemes.primaryButtonStyle,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Capture Photo'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  onUploadPhoto();
                },
                style: AppThemes.primaryButtonStyle,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Upload Photo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

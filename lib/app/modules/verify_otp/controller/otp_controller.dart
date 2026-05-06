import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';

class OtpController extends GetxController {
  final int length = 6;
  final List<TextEditingController> controllers = [];
  final List<FocusNode> focusNodes = [];

  final otp = ''.obs;
  final isValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    for (var i = 0; i < length; i++) {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }
    if (focusNodes.isNotEmpty) focusNodes[0].requestFocus();
  }

  void onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index + 1 < length) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    } else {
      if (index - 1 >= 0) focusNodes[index - 1].requestFocus();
    }
    _updateOtp();
  }

  void _updateOtp() {
    otp.value = controllers.map((c) => c.text).join();
    isValid.value = otp.value.length == length &&
        controllers.every((c) => c.text.trim().isNotEmpty);
  }

  void resend() {
    Get.snackbar('Resend', 'OTP resend requested',
        snackPosition: SnackPosition.BOTTOM);
  }

  void submit() {
    if (isValid.value) {
      Get.snackbar('OTP', 'Entered: ${otp.value}',
          snackPosition: SnackPosition.BOTTOM);
      // TODO: integrate with verification service
      // For now navigate to landing after successful verification
      Get.offAllNamed(AppRoutes.landing);
    } else {
      Get.snackbar('Error', 'Please enter the complete 6-digit code',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';

mixin OtpInputMixin on GetxController {
  static const int otpLength = 6;

  final List<TextEditingController> otpControllers = [];
  final List<FocusNode> otpFocusNodes = [];

  final otp = ''.obs;
  final isValid = false.obs;
  final displayPhone = ''.obs;

  void initOtpInputs() {
    for (var i = 0; i < otpLength; i++) {
      otpControllers.add(TextEditingController());
      otpFocusNodes.add(FocusNode());
    }
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes.first.requestFocus();
    }
  }

  void onOtpChanged(String value, int index, VoidCallback onComplete) {
    if (value.isNotEmpty) {
      if (index + 1 < otpLength) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        otpFocusNodes[index].unfocus();
      }
    } else if (index - 1 >= 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    _updateOtp(onComplete);
  }

  void _updateOtp(VoidCallback onComplete) {
    otp.value = otpControllers.map((c) => c.text).join();
    isValid.value = otp.value.length == otpLength &&
        otpControllers.every((c) => c.text.trim().isNotEmpty);

    if (isValid.value) {
      Future.delayed(const Duration(milliseconds: 300), onComplete);
    }
  }

  void resendOtp() {
    AppSnackbar.show(title: 'Resend', message: 'OTP resend requested');
  }

  void disposeOtpInputs() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in otpFocusNodes) {
      node.dispose();
    }
  }

  String formatDisplayNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('+')) return trimmed;
    return '+63 $trimmed';
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/otp_input_mixin.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/data/services/user_phone_service.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';

class CheckEligibilityVerifyOtpController extends GetxController
    with OtpInputMixin {
  String get pageTitle => 'OTP Verification';
  String get continueLabel => 'Continue';

  String get subtitle =>
      'Enter OTP sent to ${formatDisplayNumber(displayPhone.value)}';

  @override
  void onInit() {
    super.onInit();
    displayPhone.value = Get.find<UserPhoneService>().getRegisteredPhone();
    initOtpInputs();
  }

  void onChanged(String value, int index) {
    onOtpChanged(value, index, submit);
  }

  void goBackToWelcome() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back();
  }

  void resend() => resendOtp();

  void submit() {
    if (!isValid.value) {
      AppSnackbar.show(
        title: 'Error',
        message: 'Please enter the complete 6-digit code',
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.toNamed(AppRoutes.uploadId);
  }

  @override
  void onClose() {
    disposeOtpInputs();
    super.onClose();
  }
}

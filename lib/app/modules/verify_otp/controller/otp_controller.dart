import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';

import 'package:p_sosyo/app/mixins/otp_input_mixin.dart';

class OtpController extends GetxController with OtpInputMixin {
  final flow = 'register'.obs;

  bool get isLoanOfferEsign => flow.value == 'loanOfferESign';
  String get pageTitle =>
      isLoanOfferEsign ? 'E-Sign Verification' : 'OTP Verification';
  String get continueLabel => 'Continue';
  String get subtitlePrefix => isLoanOfferEsign
      ? 'Enter the code to verify your E-sign sent to '
      : 'Enter OTP sent to ';

  String get subtitle =>
      '$subtitlePrefix${formatDisplayNumber(displayPhone.value)}';

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      flow.value = (arguments['flow']?.toString()) ?? 'register';
      displayPhone.value = (arguments['phone']?.toString()) ?? '';
    } else if (arguments is String) {
      displayPhone.value = arguments;
    }

    initOtpInputs();
  }

  void onChanged(String value, int index) {
    onOtpChanged(value, index, submit);
  }

  void goBackToRegister() {
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

    AppSnackbar.show(
      title: 'OTP',
      message: 'Entered: ${otp.value}',
      margin: const EdgeInsets.all(16),
    );

    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    if (isLoanOfferEsign) {
      Get.offNamed(AppRoutes.loanSuccessful);
      return;
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offNamed(AppRoutes.dashboard);
      });
    });
  }

  @override
  void onClose() {
    disposeOtpInputs();
    super.onClose();
  }
}

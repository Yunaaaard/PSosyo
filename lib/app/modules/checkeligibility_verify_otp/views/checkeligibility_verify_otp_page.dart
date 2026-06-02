import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/otp_input_mixin.dart';
import 'package:p_sosyo/app/widgets/otp_verification_layout.dart';

import '../controllers/checkeligibility_verify_otp_controller.dart';

class CheckEligibilityVerifyOtpPage
    extends GetView<CheckEligibilityVerifyOtpController> {
  const CheckEligibilityVerifyOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        controller.goBackToWelcome();
      },
      child: OtpVerificationLayout(
        variant: OtpVerificationVariant.register,
        illustrationAsset: 'assets/icons/otp-verification-page.svg',
        pageTitle: controller.pageTitle,
        subtitle: controller.subtitle,
        controllers: controller.otpControllers,
        focusNodes: controller.otpFocusNodes,
        length: OtpInputMixin.otpLength,
        isValid: controller.isValid,
        continueLabel: controller.continueLabel,
        onChanged: controller.onChanged,
        onContinue: controller.submit,
        onResend: controller.resend,
      ),
    );
  }
}

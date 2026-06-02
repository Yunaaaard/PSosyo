import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/otp_input_mixin.dart';
import 'package:p_sosyo/app/widgets/otp_verification_layout.dart';

import '../controller/otp_controller.dart';

class OtpVerificationPage extends GetView<OtpController> {
  const OtpVerificationPage({super.key, this.phoneNumber = ''});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        controller.goBackToRegister();
      },
      child: Obx(() {
        final subtitle = controller.displayPhone.value.isNotEmpty
            ? controller.subtitle
            : '${controller.subtitlePrefix}${controller.formatDisplayNumber(phoneNumber)}';
        final variant = controller.isLoanOfferEsign
            ? OtpVerificationVariant.register
            : OtpVerificationVariant.eligibility;

        final illustration = controller.isLoanOfferEsign
            ? 'assets/icons/otp-verification-page.svg'
            : 'assets/images/otp_verification_eligibility.svg';

        return OtpVerificationLayout(
          variant: variant,
          illustrationAsset: illustration,
          pageTitle: controller.pageTitle,
          subtitle: subtitle,
          controllers: controller.otpControllers,
          focusNodes: controller.otpFocusNodes,
          length: OtpInputMixin.otpLength,
          isValid: controller.isValid,
          continueLabel: controller.continueLabel,
          onChanged: controller.onChanged,
          onContinue: controller.submit,
          onResend: controller.resend,
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';

class OtpController extends GetxController {
  final int length = 6;
  final List<TextEditingController> controllers = [];
  final List<FocusNode> focusNodes = [];

  final otp = ''.obs;
  final isValid = false.obs;
  final flow = 'register'.obs;
  final displayPhone = ''.obs;

  bool get isLoanOfferEsign => flow.value == 'loanOfferESign';
  String get pageTitle => isLoanOfferEsign ? 'E-Sign Verification' : 'OTP Verification';
  String get continueLabel => isLoanOfferEsign ? 'Continue' : 'Continue';
  String get subtitlePrefix => isLoanOfferEsign ? 'Enter the code to verify your E-sign sent to ' : 'Enter OTP sent to ';

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
    
    // Auto-submit when all 6 digits are entered
    if (isValid.value) {
      Future.delayed(const Duration(milliseconds: 300), () {
        submit();
      });
    }
  }

  void resend() {
    AppSnackbar.show(title: 'Resend', message: 'OTP resend requested');
  }

  void submit() {
    if (isValid.value) {
      AppSnackbar.show(title: 'OTP', message: 'Entered: ${otp.value}', margin: const EdgeInsets.all(16));

      // Ensure keyboard/focus is dismissed and any overlays are closed
      FocusManager.instance.primaryFocus?.unfocus();
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

      if (isLoanOfferEsign) {
        Get.offNamed(AppRoutes.loanSuccessful);
        return;
      }

      // Navigate after a short delay and on the next frame to avoid
      // hit-test/layout races when routes change while the keyboard is closing.
      Future.delayed(const Duration(milliseconds: 400), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed(AppRoutes.dashboard);
        });
      });
    } else {
      AppSnackbar.show(title: 'Error', message: 'Please enter the complete 6-digit code');
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

import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/modules/landing_page/controller/landing_controller.dart';
import 'package:flutter/material.dart';

class RegisterController extends GetxController {
  // Observable for loading state
  var isLoading = false.obs;
  // Observable for phone number
  var phoneNumber = ''.obs;
  // TextEditingController for phone input
  final phoneController = TextEditingController();

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void sendCode() async {
    if (phoneController.text.isEmpty) return;
    // Set phone and navigate immediately (temporary flow)
    phoneNumber.value = phoneController.text;
    // Ensure any existing LandingController (and its timer) is removed
    try {
      if (Get.isRegistered<LandingController>()) {
        Get.delete<LandingController>(force: true);
      }
    } catch (_) {}

    // Navigate to OTP page and clear previous routes to avoid returning to landing
    Get.offAllNamed(AppRoutes.verifyOtp, arguments: phoneNumber.value);
  }
}

import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/modules/landing_page/controller/landing_controller.dart';
import 'package:flutter/material.dart';
import 'package:p_sosyo/app/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';
import 'package:p_sosyo/app/services/user_phone_service.dart';

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
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      AppSnackbar.show(title: 'Error', message: 'Please enter your phone number');
      return;
    }
    if (phone.length != 10) {
      AppSnackbar.show(title: 'Error', message: 'Phone number must be 10 digits');
      return;
    }
    // Set phone and navigate immediately (temporary flow)
    phoneNumber.value = phone;
    Get.find<UserPhoneService>().setRegisteredPhone(phone);
    await Get.find<PsosyoDatabaseService>().saveRegisteredPhone(phone);
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

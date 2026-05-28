import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/landing_page/controller/landing_controller.dart';
import 'package:flutter/material.dart';
import 'package:p_sosyo/app/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';
import 'package:p_sosyo/app/services/user_phone_service.dart';
class RegisterController extends GetxController {
  var isLoading = false.obs;
  var phoneNumber = ''.obs;
  final phoneController = TextEditingController();

  static const int requiredPhoneLength = 10;

  bool get isPhoneValid => phoneNumber.value.trim().length == requiredPhoneLength;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_syncPhoneNumber);
  }

  void _syncPhoneNumber() {
    phoneNumber.value = phoneController.text;
  }

  @override
  void onClose() {
    phoneController.removeListener(_syncPhoneNumber);
    phoneController.dispose();
    super.onClose();
  }

  void sendCode() async {
    if (!isPhoneValid) return;

    final phone = phoneController.text.trim();
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
    Get.toNamed(AppRoutes.verifyOtp, arguments: phoneNumber.value);
  }
}

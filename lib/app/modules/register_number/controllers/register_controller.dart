import 'package:get/get.dart';
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
    isLoading.value = true;
    phoneNumber.value = phoneController.text;
    // TODO: Add API call to send code here
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    // TODO: Navigate to verification page using Get.toNamed()
  }
}

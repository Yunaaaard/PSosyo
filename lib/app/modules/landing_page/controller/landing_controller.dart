import 'dart:async';

import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';

class LandingController extends GetxController {
  Timer? _navTimer;

  @override
  void onInit() {
    super.onInit();
    _navTimer = Timer(const Duration(seconds: 4), () {
      Get.offNamed(AppRoutes.register);
    });
  }

  @override
  void onClose() {
    _navTimer?.cancel();
    super.onClose();
  }
}

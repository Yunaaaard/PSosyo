import 'package:get/get.dart';

import '../controller/landing_controller.dart';

class LandingBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<LandingController>()) {
      Get.delete<LandingController>(force: true);
    }
    Get.put(LandingController());
  }
}

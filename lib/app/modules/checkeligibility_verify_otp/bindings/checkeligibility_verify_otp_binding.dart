import 'package:get/get.dart';

import '../controllers/checkeligibility_verify_otp_controller.dart';

class CheckEligibilityVerifyOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckEligibilityVerifyOtpController>(
      () => CheckEligibilityVerifyOtpController(),
    );
  }
}

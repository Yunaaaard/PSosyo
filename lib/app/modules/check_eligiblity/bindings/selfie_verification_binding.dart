import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/selfie_verification_controller.dart';

class SelfieVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SelfieVerificationController>(
      SelfieVerificationController(),
    );
  }
}

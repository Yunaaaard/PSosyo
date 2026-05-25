import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/selfie_verification_controller.dart';
import 'package:p_sosyo/app/services/id_verification_service.dart';

class SelfieVerificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IdVerificationService>()) {
      Get.put<IdVerificationService>(
        IdVerificationService(),
        permanent: true,
      );
    }
    Get.put<SelfieVerificationController>(
      SelfieVerificationController(),
    );
  }
}

import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/selfie_verification_controller.dart';
import 'package:p_sosyo/app/services/id_verification_service.dart';

class SelfieVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IdVerificationService>(() => IdVerificationService(), fenix: true);
    Get.put<SelfieVerificationController>(
      SelfieVerificationController(),
    );
  }
}

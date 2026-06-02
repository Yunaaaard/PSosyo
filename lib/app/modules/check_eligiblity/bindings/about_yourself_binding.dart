import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/about_yourself_controller.dart';
import 'package:p_sosyo/app/data/services/id_verification_service.dart';

class AboutYourselfBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IdVerificationService>()) {
      Get.put<IdVerificationService>(
        IdVerificationService(),
        permanent: true,
      );
    }
    Get.put<AboutYourselfController>(AboutYourselfController());
  }
}

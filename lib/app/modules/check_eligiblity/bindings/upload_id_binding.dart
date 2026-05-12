import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/upload_id_controller.dart';
import 'package:p_sosyo/app/services/id_verification_service.dart';

class UploadIdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IdVerificationService>(
      () => IdVerificationService(), 
      fenix: true
    );
    Get.lazyPut<UploadIdController>(
      () => UploadIdController()
    );
  }
}

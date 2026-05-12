import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/about_yourself_controller.dart';
import 'package:p_sosyo/app/services/id_verification_service.dart';

class AboutYourselfBinding extends Bindings {
	@override
	void dependencies() {
		Get.lazyPut<IdVerificationService>(() => IdVerificationService(), fenix: true);
		Get.put<AboutYourselfController>(
      AboutYourselfController()
      );
	}
}


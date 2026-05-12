import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/about_yourself_controller.dart';

class AboutYourselfBinding extends Bindings {
	@override
	void dependencies() {
		Get.put<AboutYourselfController>(
      AboutYourselfController()
      );
	}
}

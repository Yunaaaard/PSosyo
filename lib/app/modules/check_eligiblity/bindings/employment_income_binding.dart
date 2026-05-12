import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/employment_income_controller.dart';

class EmploymentIncomeBinding extends Bindings {
	@override
	void dependencies() {
		Get.put<EmploymentIncomeController>(EmploymentIncomeController());
	}
}
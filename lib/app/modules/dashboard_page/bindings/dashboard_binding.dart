import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/dashboard_page/controller/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
  }
}

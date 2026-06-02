import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/data/services/receipt_ocr_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReceiptOcrService>(
      () => ReceiptOcrService(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}

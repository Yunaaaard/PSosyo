import 'package:get/get.dart';
import '../controllers/liveness_controller.dart';

class LivenessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LivenessController>(() => LivenessController());
  }
}

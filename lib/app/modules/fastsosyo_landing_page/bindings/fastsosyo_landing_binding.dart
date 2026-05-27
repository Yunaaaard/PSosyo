import 'package:get/get.dart';

import '../controllers/fastsosyo_landing_controller.dart';

class FastSosyoLandingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FastSosyoLandingController>(() => FastSosyoLandingController());
  }
}


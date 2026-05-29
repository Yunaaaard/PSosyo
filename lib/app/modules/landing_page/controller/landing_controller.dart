import 'dart:async';

import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';

class LandingController extends GetxController {
  Timer? _navTimer;
  late final String _nextRoute;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    final nextRoute =
        arguments is Map ? arguments['nextRoute']?.toString().trim() ?? '' : '';
    _nextRoute = nextRoute.isNotEmpty ? nextRoute : AppRoutes.psosyoWelcome;

    _navTimer = Timer(const Duration(seconds: 4), () {
      Get.offNamed(_nextRoute);
    });
  }

  @override
  void onClose() {
    _navTimer?.cancel();
    super.onClose();
  }
}

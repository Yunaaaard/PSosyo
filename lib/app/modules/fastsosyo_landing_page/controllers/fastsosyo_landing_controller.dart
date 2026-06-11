import 'dart:async';

import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';

class FastSosyoLandingController extends GetxController {
  final title = 'paqner';

  final isLogoVisible = false.obs;
  final isTitleVisible = false.obs;
  final visibleLetters = 0.obs;

  Timer? _navTimer;
  Timer? _lettersTimer;

  @override
  void onInit() {
    super.onInit();

    isLogoVisible.value = true;

    Future<void>.delayed(const Duration(milliseconds: 3000), () {
      isTitleVisible.value = true;
      _startLetterAnimation();
    });

    _navTimer = Timer(const Duration(seconds: 7), () {
      Get.offNamed(AppRoutes.register);
    });
  }

  void _startLetterAnimation() {
    _lettersTimer?.cancel();
    visibleLetters.value = 0;

    var i = 0;
    _lettersTimer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      i++;
      if (i > title.length) {
        t.cancel();
        return;
      }
      visibleLetters.value = i;
    });
  }

  @override
  void onClose() {
    _navTimer?.cancel();
    _lettersTimer?.cancel();
    super.onClose();
  }
}


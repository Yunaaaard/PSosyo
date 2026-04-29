import 'package:get/get.dart';
import 'package:flutter/animation.dart';
import 'package:p_sosyo/app/animations/fade_in_animation.dart';

class LandingController extends GetxController with GetSingleTickerProviderStateMixin {
  late FadeInAnimation fadeInAnimation;
  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    fadeInAnimation = FadeInAnimation(vsync: this);
    fadeInAnimation.start();
    fadeInAnimation.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isReady.value = true;
      }
    });
  }

  Animation<double> get fadeAnim => fadeInAnimation.fadeAnim;

  @override
  void onClose() {
    fadeInAnimation.dispose();
    super.onClose();
  }
}

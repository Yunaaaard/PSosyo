import 'package:flutter/animation.dart';

class FadeInAnimation {
  final AnimationController controller;
  late final Animation<double> fadeAnim;

  FadeInAnimation({required TickerProvider vsync, Duration? duration})
      : controller = AnimationController(
          vsync: vsync,
          duration: duration ?? const Duration(milliseconds: 1200),
        ) {
    fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeIn);
  }

  void start() => controller.forward();

  void dispose() => controller.dispose();
}

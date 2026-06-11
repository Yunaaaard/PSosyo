import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/fastsosyo_landing_controller.dart';

class FastSosyoLandingScreen extends GetView<FastSosyoLandingController> {
  const FastSosyoLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/landing-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                child: Center(
                  child: Obx(() {
                    return AnimatedOpacity(
                      opacity: controller.isLogoVisible.value ? 1 : 0,
                      duration: const Duration(milliseconds: 3000),
                      curve: Curves.easeIn,
                      child: Image.asset(
                        'assets/images/paqner-logo-blue.png',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(
                height: 90,
                child: Obx(() {
                  if (!controller.isTitleVisible.value) {
                    return const SizedBox.shrink();
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(controller.visibleLetters.value, (i) {
                      final letter = controller.title[i];
                      return TweenAnimationBuilder<double>(
                        key: ValueKey('$i-$letter-${controller.visibleLetters.value}'),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontFamily: 'Blinko - Demo',
                            fontWeight: FontWeight.w500,
                            fontSize: 70,
                            color: Color(0xFF366EFB),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
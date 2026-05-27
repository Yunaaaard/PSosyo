import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/fastsosyo_landing_controller.dart';

class FastSosyoLandingScreen extends GetView<FastSosyoLandingController> {
  const FastSosyoLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
                      'assets/images/FastSosyo.png',
                      width: 240,
                      fit: BoxFit.contain,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
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
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 32,
                          color: Color(0xFF0000BC),
                          letterSpacing: 6,
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
    );
  }
}


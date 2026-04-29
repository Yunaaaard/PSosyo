import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import '../controllers/landing_controller.dart';


class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LandingController>(
      init: LandingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Center(
            child: FadeTransition(
              opacity: controller.fadeAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/PSosyo-Logo.png',
                    width: 250,
                    height: 250,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Psosyo',
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 80,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
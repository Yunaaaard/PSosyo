import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/core/themes/theme_colors.dart';

import '../controller/landing_controller.dart';

class LandingPage extends GetView<LandingController> {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/PSOSYO-LOGO.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 5),
            const Text(
              'PESOPAQ',
              style: TextStyle(
                fontFamily: 'IT TENOVIANA DEMO',
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 50,
                fontWeight: FontWeight.w400,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

import '../controller/landing_controller.dart';

class LandingPage extends GetView<LandingController> {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Touch controller so splash navigation timer always starts.
    controller;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/psosyo-icon-button.svg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 5),
            const Text(
              'PSOSYO',
              style: TextStyle(
                fontFamily: 'IT TENOVIANA DEMO',
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 24,
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

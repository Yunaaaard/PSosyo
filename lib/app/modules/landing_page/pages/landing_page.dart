import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import '../controller/landing_controller.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/PSOSYO-LOGO.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 5),
            const Text(
              'PSOSYO',
              style: const TextStyle(
                fontFamily: 'IT TENOVIANA DEMO',
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 60,
                fontWeight: FontWeight.w400,
                letterSpacing: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
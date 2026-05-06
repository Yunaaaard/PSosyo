import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import '../controller/otp_controller.dart';
import 'package:p_sosyo/app/animations/keyboard_shrink_animation.dart';

class OtpVerificationPage extends StatelessWidget {
  final String phoneNumber;

  const OtpVerificationPage({Key? key, this.phoneNumber = '+93 9453482113'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();
    final displayNumber = (Get.arguments as String?) ?? phoneNumber;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ShrinkOnKeyboard(
            child: Column(
              children: [
                const SizedBox(height: 24),
                SvgPicture.asset(
                  'assets/icons/otp-verification-page.svg',
                  width: 260,
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 8),
                const Text('OTP Verification',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Enter OTP sent to $displayNumber',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  const horizontalPadding =
                      40.0; // left+right content padding approx
                  const spacing = 12.0; // gap between boxes
                  final available =
                      (totalWidth - horizontalPadding).clamp(0.0, totalWidth);
                  final count = controller.length;
                  var boxWidth = (available - spacing * (count - 1)) / count;
                  if (boxWidth > 56) boxWidth = 56;
                  final boxHeight = boxWidth;

                  final children = <Widget>[];
                  for (var i = 0; i < count; i++) {
                    children.add(SizedBox(
                      width: boxWidth,
                      height: boxHeight,
                      child: TextField(
                        controller: controller.controllers[i],
                        focusNode: controller.focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1)
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          counterText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                        ),
                        onChanged: (v) => controller.onChanged(v, i),
                      ),
                    ));

                    if (i != count - 1)
                      children.add(const SizedBox(width: spacing));
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('You didn\'t receive any code?',
                        style: TextStyle(color: Colors.grey[600])),
                    TextButton(
                        onPressed: controller.resend,
                        child: const Text('Resend')),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: Obx(() {
                      if (controller.isValid.value) {
                        return ElevatedButton(
                          onPressed: controller.submit,
                          style: AppThemes.primaryButtonStyle,
                          child: const Text('Continue'),
                        );
                      }

                      // Disabled / empty state: smaller, muted button
                      return ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: const Text('Continue',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

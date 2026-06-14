import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/core/themes/theme_colors.dart';

import '../controllers/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  static const primaryBlue = Color(0xFF275DCE);

  ButtonStyle get _enabledButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryBlue,
        disabledForegroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
          fontFamily: 'Poppins',
          fontSize: 25,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        minimumSize: const Size(500, 65),
        maximumSize: const Size(500, 65),
      );

  @override
  Widget build(BuildContext context) {
    final primaryBlue70 = primaryBlue.withOpacity(0.7);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.offNamed(AppRoutes.landing);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Image.asset(
                  'assets/images/register_number.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  'Enter your Registered Number',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We will send you the 6-digit verification code',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryBlue70, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Star.svg',
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              primaryBlue70,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '+63',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: primaryBlue70),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryBlue70, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.number,
                          cursorColor: primaryBlue,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _PhilippinePhoneFormatter(),
                            LengthLimitingTextInputFormatter(
                              RegisterController.requiredPhoneLength,
                            ),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Enter phone number',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (val) => controller.phoneNumber.value = val,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'By entering the Lending app, you have agreed to the terms and privacy policy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontSize: 15,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Obx(() {
                  final isEnabled =
                      controller.isPhoneValid && !controller.isLoading.value;

                  return Center(
                    child: ElevatedButton(
                      style: isEnabled
                          ? _enabledButtonStyle
                          : AppThemes.unaccessibleButtonStyle,
                      onPressed: isEnabled ? controller.sendCode : null,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send Code'),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Formatter that removes leading 0 from Philippine phone numbers
/// Since +63 is the country code, the leading 0 should be removed
class _PhilippinePhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // If input starts with 0 and has more than 1 digit, remove the leading 0
    if (text.startsWith('0') && text.length > 1) {
      text = text.substring(1);
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    return newValue;
  }
}

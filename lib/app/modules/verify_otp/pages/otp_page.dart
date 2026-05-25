import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import '../controller/otp_controller.dart';
import 'package:p_sosyo/app/animations/keyboard_shrink_animation.dart';

class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({Key? key, this.phoneNumber = ''})
      : super(key: key);

  final String phoneNumber;

  String _formatDisplayNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return phoneNumber;
    if (trimmed.startsWith('+')) return trimmed;
    return '+63 $trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();
    final displayNumber = controller.displayPhone.value.isNotEmpty
      ? _formatDisplayNumber(controller.displayPhone.value)
      : _formatDisplayNumber(phoneNumber);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ShrinkOnKeyboard(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  const horizontalPadding = 40.0;
                  const spacing = 12.0;
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
                        autofocus: i == 0,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        textInputAction: i == count - 1
                            ? TextInputAction.done
                            : TextInputAction.next,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onChanged: (v) => controller.onChanged(v, i),
                        onSubmitted: (v) {
                          if (i + 1 < count) {
                            controller.focusNodes[i + 1].requestFocus();
                          } else {
                            controller.focusNodes[i].unfocus();
                            if (controller.isValid.value) {
                              controller.submit();
                            }
                          }
                        },
                      ),
                    ));

                    if (i != count - 1) {
                      children.add(const SizedBox(width: spacing));
                    }
                  }

                  final rowWidth = (boxWidth * count) + (spacing * (count - 1));

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          SvgPicture.asset(
                            'assets/icons/otp-verification-page.svg',
                            width: 260,
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          Obx(() {
                            return Column(
                              children: [
                                Text(
                                  controller.pageTitle,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${controller.subtitlePrefix}$displayNumber',
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 24),
                          Center(
                            child: SizedBox(
                              width: rowWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: children,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'You didn\'t receive any code?',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: controller.resend,
                                child: const Text('Resend'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: Obx(() {
                                final isEnabled = controller.isValid.value;

                                return ElevatedButton(
                                  onPressed:
                                      isEnabled ? controller.submit : null,
                                  style: isEnabled
                                      ? AppThemes.primaryButtonStyle
                                      : AppThemes.unaccessibleButtonStyle,
                                  child: Obx(() => Text(controller.continueLabel)),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
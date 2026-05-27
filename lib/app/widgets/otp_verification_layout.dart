import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

enum OtpVerificationVariant {
  /// Register / send-code flow — purple theme.
  register,

  /// Check eligibility flow — FastSosyo blue theme.
  eligibility,
}

class OtpVerificationLayout extends StatelessWidget {
  const OtpVerificationLayout({
    super.key,
    required this.variant,
    required this.illustrationAsset,
    required this.pageTitle,
    required this.subtitle,
    required this.controllers,
    required this.focusNodes,
    required this.length,
    required this.isValid,
    required this.continueLabel,
    required this.onChanged,
    required this.onContinue,
    required this.onResend,
    this.onFieldSubmitted,
  });

  final OtpVerificationVariant variant;
  final String illustrationAsset;
  final String pageTitle;
  final String subtitle;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final int length;
  final RxBool isValid;
  final String continueLabel;
  final void Function(String value, int index) onChanged;
  final VoidCallback onContinue;
  final VoidCallback onResend;
  final void Function(int index)? onFieldSubmitted;

  Color get _accentColor => variant == OtpVerificationVariant.register
      ? AppColors.primary
      : const Color(0xFF275DCE);

  ButtonStyle get _enabledButtonStyle {
    if (variant == OtpVerificationVariant.register) {
      return AppThemes.primaryButtonStyle;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: _accentColor,
      foregroundColor: Colors.white,
      disabledBackgroundColor: _accentColor,
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
  }

  Widget _buildIllustration() {
    return SvgPicture.asset(
      illustrationAsset,
      width: 260,
      height: 220,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                const spacing = 8.0;
                var boxSize = (totalWidth - spacing * (length - 1)) / length;
                if (boxSize > 76) boxSize = 76;

                final children = <Widget>[];
                for (var i = 0; i < length; i++) {
                  children.add(SizedBox(
                    width: boxSize,
                    height: boxSize,
                    child: TextField(
                      controller: controllers[i],
                      focusNode: focusNodes[i],
                      autofocus: i == 0,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: _accentColor,
                      textInputAction: i == length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.1,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: _accentColor,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => onChanged(value, i),
                      onSubmitted: (_) {
                        if (onFieldSubmitted != null) {
                          onFieldSubmitted!(i);
                          return;
                        }
                        if (i + 1 < length) {
                          focusNodes[i + 1].requestFocus();
                        } else {
                          focusNodes[i].unfocus();
                          if (isValid.value) onContinue();
                        }
                      },
                    ),
                  ));

                  if (i != length - 1) {
                    children.add(const SizedBox(width: spacing));
                  }
                }

                final rowWidth = (boxSize * length) + (spacing * (length - 1));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            _buildIllustration(),
                            const SizedBox(height: 20),
                            Text(
                              pageTitle,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
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
                                  onPressed: onResend,
                                  style: TextButton.styleFrom(
                                    foregroundColor: _accentColor,
                                  ),
                                  child: const Text(
                                    'Resend',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Obx(() {
                      final enabled = isValid.value;

                      return Center(
                        child: ElevatedButton(
                          onPressed: enabled ? onContinue : null,
                          style: enabled
                              ? _enabledButtonStyle
                              : AppThemes.unaccessibleButtonStyle,
                          child: Text(continueLabel),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:p_sosyo/app/modules/loan_offer/pages/loan_offer.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

class VerifyingProcessPage extends StatefulWidget {
  const VerifyingProcessPage({super.key});

  @override
  State<VerifyingProcessPage> createState() => _VerifyingProcessPageState();
}

class _VerifyingProcessPageState extends State<VerifyingProcessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _stopTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _animationController.stop();
        Get.offAll(() => const LoanOfferPage());
      }
    });
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final pulse = _animationController.value;
                    final scale = 0.96 + (pulse * 0.08);
                    final opacity = 0.7 + (pulse * 0.3);

                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: child,
                      ),
                    );
                  },
                  child: const _VerificationIcon(),
                ),
                const SizedBox(height: 42),
                Text(
                  'Verifying your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.darkText,
                    fontSize: 28,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your information is currently being reviewed.\nPlease wait while we complete the verification\nprocess.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.titleGrey,
                    fontSize: 18,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationIcon extends StatelessWidget {
  const _VerificationIcon();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.lightPurple,
            ),
          ),
          Container(
            width: 290,
            height: 290,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primaryPurple.withOpacity(0.08),
                width: 2,
              ),
            ),
          ),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: colors.primaryPurple.withOpacity(0.10),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/verifying-process-icon.svg',
            width: 210,
            height: 210,
            fit: BoxFit.contain,
          ),
          Positioned(
            bottom: 26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LoadingDot(color: colors.primaryPurple, delay: 0),
                const SizedBox(width: 8),
                _LoadingDot(color: colors.primaryPurple, delay: 1),
                const SizedBox(width: 8),
                _LoadingDot(color: colors.primaryPurple, delay: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDot extends StatefulWidget {
  const _LoadingDot({required this.color, required this.delay});

  final Color color;
  final int delay;

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = ((_controller.value + (widget.delay * 0.18)) % 1.0);
        final opacity = 0.35 + (phase * 0.65);
        final scale = 0.8 + (phase * 0.35);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
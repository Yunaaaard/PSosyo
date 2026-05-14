import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

class LoanOfferAppBar extends StatelessWidget {
  const LoanOfferAppBar({super.key, required this.colors});

  final PsosyoThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.titleGrey,
            size: 22,
          ),
        ),
        const Spacer(),
        Text(
          'Loan Offer',
          style: TextStyle(
            color: colors.darkText,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 22),
      ],
    );
  }
}

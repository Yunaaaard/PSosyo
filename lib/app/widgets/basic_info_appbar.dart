import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';

class BasicInfoAppBar extends StatelessWidget {
  final VoidCallback? onBack;
  final String title;

  const BasicInfoAppBar({Key? key, this.onBack, this.title = 'Basic Information'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

    return Row(
      children: [
        GestureDetector(
          onTap: onBack ?? () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.titleGrey,
            size: 22,
          ),
        ),
        const Spacer(),
        Text(
          title,
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

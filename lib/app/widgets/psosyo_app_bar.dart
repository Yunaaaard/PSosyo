import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PsosyoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PsosyoAppBar({
    super.key,
    this.title = 'PAQNER',
    this.onBack,
    this.showBackButton = true,
    this.backgroundColor = Colors.transparent,
    this.titleColor = const Color(0xFF6B3DF0),
    this.iconColor = const Color(0xFFB9B9C1),
    this.titleFontSize = 26,
    this.height = 62,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Color backgroundColor;
  final Color titleColor;
  final Color iconColor;
  final double titleFontSize;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: showBackButton
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.chevron_left,
                      color: iconColor,
                      size: 34,
                    ),
                    onPressed: onBack ?? () => Get.back(),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w800,
                color: titleColor,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
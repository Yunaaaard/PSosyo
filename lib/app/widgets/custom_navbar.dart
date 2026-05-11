import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CustomNavBar({Key? key, this.currentIndex = 0, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (i) {
          final isActive = i == currentIndex;
          final icons = [
            'assets/icons/navigate-home.svg',
            'assets/icons/navigate-history.svg',
            'assets/icons/navigate-pos.svg',
            'assets/icons/navigate-profile.svg'
          ];
          final labels = ['Home', 'History', 'POS', 'Profile'];

          return GestureDetector(
            onTap: () => onTap?.call(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isActive)
                  Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(4)))
                else
                  const SizedBox(height: 3),
                const SizedBox(height: 6),
                SvgPicture.asset(
                  icons[i],
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    isActive ? Colors.blueAccent : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
                Text(labels[i],
                    style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.blueAccent : Colors.grey)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

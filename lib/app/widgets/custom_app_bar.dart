import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, this.title = 'PSOSYO'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {},
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF6533E7),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: SvgPicture.asset('assets/icons/search-normal.svg', width: 20, height: 20),
              onPressed: () {},
            ),
            IconButton(
              icon: SvgPicture.asset('assets/icons/notification.svg', width: 20, height: 20),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

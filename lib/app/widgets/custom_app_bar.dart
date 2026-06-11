import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, this.title = 'paqner'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(255, 16, 98, 221),
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                  fontFamily: 'Blinko - Demo',
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () {},
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
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

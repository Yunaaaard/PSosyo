import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/landing_page/pages/landing_page.dart';
import 'app/services/user_phone_service.dart';
import 'app/utils/themes/theme_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  Get.put(UserPhoneService(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PSosyo',
      theme: AppThemes.lightTheme,
      home: const LandingPage(),
      getPages: AppPages.pages,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(0.7),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

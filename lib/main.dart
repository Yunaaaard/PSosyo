import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/services/app_state_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/user_phone_service.dart';
import 'app/utils/themes/theme_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Get.putAsync<PsosyoDatabaseService>(
    () => PsosyoDatabaseService().init(),
    permanent: true,
  );
  final appStateService = await Get.putAsync<AppStateService>(
    () => AppStateService().init(),
    permanent: true,
  );
  Get.put(UserPhoneService(), permanent: true);
  final initialRoute = appStateService.getLastRoute() ?? AppRoutes.landing;
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FASTSYOSYO',
      theme: AppThemes.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      routingCallback: (routing) {
        final currentRoute = routing?.current;
        if (currentRoute == null || currentRoute.isEmpty) {
          return;
        }

        final isAppRoute =
            AppPages.pages.any((page) => page.name == currentRoute);
        if (!isAppRoute) {
          return;
        }

        try {
          unawaited(Get.find<AppStateService>().saveLastRoute(currentRoute));
        } catch (_) {}
      },
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

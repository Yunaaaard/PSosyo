import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateService extends GetxService {
  static const String _lastRouteKey = 'last_route';

  late final SharedPreferences _preferences;

  Future<AppStateService> init() async {
    _preferences = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveLastRoute(String routeName) async {
    final route = routeName.trim();
    if (route.isEmpty) {
      return;
    }

    await _preferences.setString(_lastRouteKey, route);
  }

  String? getLastRoute() {
    final route = _preferences.getString(_lastRouteKey)?.trim();
    if (route == null || route.isEmpty) {
      return null;
    }

    return route;
  }
}

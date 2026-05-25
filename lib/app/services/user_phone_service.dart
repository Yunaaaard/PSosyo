import 'package:get/get.dart';

class UserPhoneService extends GetxService {
  final registeredPhone = ''.obs;

  void setRegisteredPhone(String value) {
    registeredPhone.value = value;
  }

  String getRegisteredPhone() {
    return registeredPhone.value;
  }
}

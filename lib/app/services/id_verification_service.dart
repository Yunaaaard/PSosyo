import 'package:get/get.dart';

class IdVerificationService extends GetxService {
  var scannedName = Rx<String?>(null);

  void setScannedName(String? name) {
    scannedName.value = name;
  }

  String? getScannedName() {
    return scannedName.value;
  }

  void clearScannedName() {
    scannedName.value = null;
  }
}

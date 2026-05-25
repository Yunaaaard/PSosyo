import 'package:get/get.dart';

class IdVerificationService extends GetxService {
  var scannedName = Rx<String?>(null);
  var scannedBirthDate = Rx<String?>(null);
  var scannedGender = Rx<String?>(null);

  void setScannedName(String? name) {
    scannedName.value = name;
  }

  String? getScannedName() {
    return scannedName.value;
  }

  void setScannedBirthDate(String? birthDate) {
    scannedBirthDate.value = birthDate;
  }

  String? getScannedBirthDate() {
    return scannedBirthDate.value;
  }

  void setScannedGender(String? gender) {
    scannedGender.value = gender;
  }

  String? getScannedGender() {
    return scannedGender.value;
  }

  void clearScannedName() {
    scannedName.value = null;
  }

  void clearScannedBirthDate() {
    scannedBirthDate.value = null;
  }

  void clearScannedData() {
    scannedName.value = null;
    scannedBirthDate.value = null;
    scannedGender.value = null;
  }
}

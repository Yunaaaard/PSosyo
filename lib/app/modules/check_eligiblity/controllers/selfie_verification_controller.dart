import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SelfieVerificationController extends GetxController {
  var isLivenessCheckStarted = false.obs;
  var isPhotoTaken = false.obs;
  var isCapturing = false.obs;
  var selfieFile = Rx<XFile?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> startLivenessCheck() async {
    isLivenessCheckStarted.value = true;
    isCapturing.value = true;

    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) {
      isCapturing.value = false;
      return;
    }

    selfieFile.value = file;
    isPhotoTaken.value = true;
    isCapturing.value = false;
  }

  void setPhotoTaken(bool taken) {
    isPhotoTaken.value = taken;
    isCapturing.value = false;
  }

  void resetState() {
    isLivenessCheckStarted.value = false;
    isPhotoTaken.value = false;
    isCapturing.value = false;
    selfieFile.value = null;
  }

  void continueToPreviousStep() {
    Get.back();
  }
}

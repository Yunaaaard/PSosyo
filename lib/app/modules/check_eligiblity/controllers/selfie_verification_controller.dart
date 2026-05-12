import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SelfieVerificationController extends GetxController {
  var isLivenessCheckStarted = false.obs;
  var isPhotoTaken = false.obs;
  var isCapturing = false.obs;
  var selfieFile = Rx<XFile?>(null);

  final ImagePicker _picker = ImagePicker();

  /// Open the camera and capture a selfie.
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

  /// Mark photo as taken
  void setPhotoTaken(bool taken) {
    isPhotoTaken.value = taken;
    isCapturing.value = false;
  }

  /// Reset state
  void resetState() {
    isLivenessCheckStarted.value = false;
    isPhotoTaken.value = false;
    isCapturing.value = false;
    selfieFile.value = null;
  }

  /// Proceed to next step
  void continueToPreviousStep() {
    // Navigate to the next step or previous step as needed
    Get.back();
  }
}

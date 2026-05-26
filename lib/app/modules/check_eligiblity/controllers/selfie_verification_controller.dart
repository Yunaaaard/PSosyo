import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/pages/liveness_verification_page.dart';
import '../models/liveness_models.dart';

class SelfieVerificationController extends GetxController {
  var isLivenessCheckStarted = false.obs;
  var isPhotoTaken = false.obs;
  var isCapturing = false.obs;
  var selfieFile = Rx<XFile?>(null);

  Future<void> startLivenessCheck() async {
    isLivenessCheckStarted.value = true;
    isCapturing.value = true;

    // Navigate to LivenessVerificationPage and await the result.
    // Returns a LivenessResult with an imagePath on success, or null on cancel/failure.
    final result = await Get.to<LivenessResult?>(
      () => const LivenessVerificationPage(),
    );

    if (result != null) {
      selfieFile.value = XFile(result.imagePath);
      isPhotoTaken.value = true;
    }

    isLivenessCheckStarted.value = false;
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

import 'package:get/get.dart';
import '../controllers/liveness_controller.dart';
import '../../../services/camera_service.dart';
import '../../../services/face_detection_service.dart';

/// Binding for LivenessVerificationPage.
/// Manages dependency injection for camera and face detection services,
/// as well as the liveness controller that orchestrates them.
class LivenessBinding extends Bindings {
  @override
  void dependencies() {
    // Register services first
    Get.put<CameraService>(CameraService());
    Get.put<FaceDetectionService>(FaceDetectionService());

    // Register controller with injected services
    Get.lazyPut<LivenessController>(
      () => LivenessController(
        cameraService: Get.find<CameraService>(),
        faceDetectionService: Get.find<FaceDetectionService>(),
      ),
    );
  }
}

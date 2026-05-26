import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

/// Service to manage camera initialization and lifecycle.
/// Handles camera setup, frame streaming, and disposal.
class CameraService extends GetxService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  final isInitialized = false.obs;

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      _cameraController = controller;
      isInitialized.value = true;
    } catch (e) {
      isInitialized.value = false;
      rethrow;
    }
  }

  void startImageStream(Function(CameraImage) onFrame) {
    _cameraController?.startImageStream(onFrame);
  }

  Future<void> stopImageStream() async {
    await _cameraController?.stopImageStream();
  }

  Future<XFile?> takePicture() async {
    return await _cameraController?.takePicture();
  }

  void dispose() {
    _cameraController?.dispose();
    _cameraController = null;
    isInitialized.value = false;
  }

  @override
  void onClose() {
    dispose();
    super.onClose();
  }
}

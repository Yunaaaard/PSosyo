import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import '../models/liveness_models.dart';
import '../../../services/camera_service.dart';
import '../../../services/face_detection_service.dart';

/// Orchestrates the liveness verification flow.
/// Coordinates camera service, face detection service, and challenge logic.
/// Follows GetX best practice: controller manages business logic, not infrastructure.
class LivenessController extends GetxController with WidgetsBindingObserver {
  // Services (injected via binding)
  final CameraService cameraService;
  final FaceDetectionService faceDetectionService;

  // For convenience
  CameraController? get cameraController => cameraService.cameraController;
  Rx<bool> get cameraInitialized => cameraService.isInitialized;

  // Challenge state
  final challenges = <Challenge>[Challenge.movement, Challenge.smile];
  final currentChallengeIndex = 0.obs;
  final movementStarted = false.obs;
  final challengeComplete = false.obs;

  // Status
  final statusMessage = 'Position your face in the circle'.obs;
  final faceDetected = false.obs;
  final succeeded = false.obs;
  final timedOut = false.obs;

  // Timeout
  Timer? _timeoutTimer;
  final secondsLeft = 40.obs;

  var _isProcessingFrame = false;

  LivenessController({
    required this.cameraService,
    required this.faceDetectionService,
  });

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _startTimeout();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeoutTimer?.cancel();
    cameraService.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraInitialized.value) return;
    if (state == AppLifecycleState.inactive) {
      cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      await cameraService.initializeCamera();
      cameraService.startImageStream(_processFrame);
      update(); // Notify GetBuilder that camera is ready
    } catch (e) {
      statusMessage.value = 'Failed to initialize camera';
      update();
    }
  }

  void _startTimeout() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      secondsLeft.value--;
      update(); // Notify GetBuilder of countdown change
      if (secondsLeft.value <= 0) {
        t.cancel();
        timedOut.value = true;
        cameraService.stopImageStream();
        update();
      }
    });
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessingFrame || succeeded.value || timedOut.value) return;
    _isProcessingFrame = true;

    try {
      final camera = cameraController?.description;
      if (camera == null) return;

      final faces = await faceDetectionService.detectFaces(image, camera);
      if (faces.isEmpty) {
        faceDetected.value = false;
        statusMessage.value = 'No face detected — move closer';
        return;
      }

      faceDetected.value = true;
      final face = faces.first;
      _evaluateChallenge(face);
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _evaluateChallenge(Face face) {
    if (challengeComplete.value) return;

    final challenge = challenges[currentChallengeIndex.value];
    if (challenge == Challenge.movement) {
      final yaw = face.headEulerAngleY ?? 0.0;
      final pitch = face.headEulerAngleX ?? 0.0;
      statusMessage.value = '👤 Nod or look left/right';

      final moved = yaw.abs() > 18.0 || pitch.abs() > 12.0;
      final neutral = yaw.abs() < 10.0 && pitch.abs() < 8.0;

      if (!movementStarted.value && moved) {
        movementStarted.value = true;
      } else if (movementStarted.value && neutral) {
        movementStarted.value = false;
        _advanceChallenge();
      }
    } else if (challenge == Challenge.smile) {
      final smileProb = face.smilingProbability ?? 0.0;
      statusMessage.value = '😊 Smile at the camera';
      if (smileProb > 0.75) _advanceChallenge();
    }
  }

  void _advanceChallenge() {
    challengeComplete.value = true;
    update();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (isClosed) return;
      if (currentChallengeIndex.value < challenges.length - 1) {
        currentChallengeIndex.value++;
        challengeComplete.value = false;
        movementStarted.value = false;
        statusMessage.value = 'Great! Next challenge…';
        update();
      } else {
        _captureAndFinish();
      }
    });
  }

  Future<void> _captureAndFinish() async {
    succeeded.value = true;
    update();
    _timeoutTimer?.cancel();

    try {
      await cameraService.stopImageStream();
      final xfile = await cameraService.takePicture();
      if (xfile != null) {
        Get.back(result: LivenessResult(imagePath: xfile.path));
      }
    } catch (_) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/liveness_selfie.jpg';
      Get.back(result: LivenessResult(imagePath: path));
    }
  }

  void retry() {
    currentChallengeIndex.value = 0;
    challengeComplete.value = false;
    succeeded.value = false;
    timedOut.value = false;
    movementStarted.value = false;
    secondsLeft.value = 40;
    faceDetected.value = false;
    statusMessage.value = 'Position your face in the circle';
    update();
    _startTimeout();
    cameraService.startImageStream(_processFrame);
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import '../models/liveness_models.dart';

class LivenessController extends GetxController with WidgetsBindingObserver {
  // Camera
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;
  final cameraInitialized = false.obs;

  // ML Kit
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  var _isProcessingFrame = false;

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
    _cameraController?.dispose();
    _faceDetector.close();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
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
    cameraInitialized.value = true;

    controller.startImageStream(_processFrame);
  }

  void _startTimeout() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      secondsLeft.value--;
      if (secondsLeft.value <= 0) {
        t.cancel();
        timedOut.value = true;
        _cameraController?.stopImageStream();
      }
    });
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessingFrame || succeeded.value || timedOut.value) return;
    _isProcessingFrame = true;

    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
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

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final bytesBuilder = BytesBuilder();
    for (final plane in image.planes) {
      bytesBuilder.add(plane.bytes);
    }
    final bytes = bytesBuilder.toBytes();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
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
    Future.delayed(const Duration(milliseconds: 600), () {
      if (isClosed) return;
      if (currentChallengeIndex.value < challenges.length - 1) {
        currentChallengeIndex.value++;
        challengeComplete.value = false;
        movementStarted.value = false;
        statusMessage.value = 'Great! Next challenge…';
      } else {
        _captureAndFinish();
      }
    });
  }

  Future<void> _captureAndFinish() async {
    succeeded.value = true;
    _timeoutTimer?.cancel();

    try {
      await _cameraController?.stopImageStream();
      final xfile = await _cameraController?.takePicture();
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
    _startTimeout();
    _cameraController?.startImageStream(_processFrame);
  }
}

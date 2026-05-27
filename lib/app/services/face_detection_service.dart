import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Service to wrap Google ML Kit Face Detection.
/// Handles face detection processing and resource management.
class FaceDetectionService extends GetxService {
  late final FaceDetector _faceDetector;

  @override
  void onInit() {
    super.onInit();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  /// Build InputImage from camera frame.
  InputImage? buildInputImage(CameraImage image, CameraDescription camera) {
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

  /// Process a camera frame and detect faces.
  Future<List<Face>> detectFaces(CameraImage image, CameraDescription camera) async {
    final inputImage = buildInputImage(image, camera);
    if (inputImage == null) return [];
    return await _faceDetector.processImage(inputImage);
  }

  @override
  void onClose() {
    _faceDetector.close();
    super.onClose();
  }
}

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/pages/id_capture_camera_page.dart';

class UploadIdService {
  static final UploadIdService _instance = UploadIdService._internal();

  factory UploadIdService() {
    return _instance;
  }

  UploadIdService._internal();

  final List<String> idOptions = [
    'National ID',
    "Driver's License",
    'Postal ID',
    'Passport',
  ];

  Future<XFile?> pickImage({
    required bool isFront,
    String? idType,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final image = await Get.to<XFile?>(
      () => IdCaptureCameraPage(
        isFront: isFront,
        idType: idType,
      ),
    );

    return image;
  }

  Future<bool> isOrientationValidForIdType(
      XFile imageFile, String? idType) async {
    if (!_requiresLandscapeOrientation(idType)) {
      return true;
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    final image = await _decodeImage(bytes);

    try {
      return image.width >= image.height;
    } finally {
      image.dispose();
    }
  }

  bool _requiresLandscapeOrientation(String? idType) {
    final normalized = (idType ?? '').trim().toLowerCase();
    if (normalized.contains('passport')) {
      return false;
    }

    return normalized.contains('national id') ||
        normalized.contains('philsys') ||
        normalized.contains('driver') ||
        normalized.contains('license') ||
        normalized.contains('postal');
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }
}

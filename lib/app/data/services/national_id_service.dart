import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:p_sosyo/app/data/models/id_scan_result.dart';
import 'package:p_sosyo/app/data/services/id_scan_service.dart';

class NationalIdService {
  NationalIdService({IdScanService? scanService})
      : _scanService = scanService ?? IdScanService();

  final IdScanService _scanService;

  Future<IdScanResult> scanFront(XFile imageFile) {
    return _scanService.extractNameFromPhilSysImage(imageFile);
  }

  Future<IdScanResult> scanFrontInputImage(InputImage image) {
    return _scanService.scanInputImage(image, idType: 'philsys');
  }

  Future<String?> readBackQrRaw(XFile imageFile) {
    return _scanService.readQrRaw(imageFile);
  }

  Future<String?> scanBackQrInputImage(InputImage image) {
    return _scanService.readQrRawFromInputImage(image);
  }

  String? extractNameFromQrRawContent(String rawQrContent) {
    return _scanService.extractNameFromQrRawContent(rawQrContent);
  }

  IdScanResult? extractAllDataFromQrRawContent(String rawQrContent) {
    return _scanService.extractAllDataFromQrRawContent(rawQrContent);
  }

  bool namesMatchApproximately(String a, String b) {
    return _scanService.namesMatchApproximately(a, b);
  }
}


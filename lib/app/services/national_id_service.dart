import 'package:image_picker/image_picker.dart';
import 'package:p_sosyo/app/services/id_scan_service.dart';

class NationalIdService {
  NationalIdService({IdScanService? scanService}) : _scanService = scanService ?? IdScanService();

  final IdScanService _scanService;

  Future<IdScanResult> scanFront(XFile imageFile) {
    return _scanService.extractNameFromPhilSysImage(imageFile);
  }

  Future<String?> readBackQrRaw(XFile imageFile) {
    return _scanService.readQrRaw(imageFile);
  }

  String? extractNameFromQrRawContent(String rawQrContent) {
    return _scanService.extractNameFromQrRawContent(rawQrContent);
  }

  bool namesMatchApproximately(String a, String b) {
    return _scanService.namesMatchApproximately(a, b);
  }
}
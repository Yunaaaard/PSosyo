import 'package:image_picker/image_picker.dart';
import 'package:p_sosyo/app/services/id_scan_service.dart';

class DriversLicenseService {
  DriversLicenseService({IdScanService? scanService}) : _scanService = scanService ?? IdScanService();

  final IdScanService _scanService;

  Future<IdScanResult> scanFront(XFile imageFile) {
    return _scanService.extractNameFromDriversLicenseImage(imageFile);
  }
}
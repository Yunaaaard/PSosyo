import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_sosyo/app/services/upload_id_service.dart';
import 'package:p_sosyo/app/services/id_scan_service.dart';
import 'package:p_sosyo/app/services/id_verification_service.dart';

class UploadIdController extends GetxController {
  final UploadIdService _service = UploadIdService();
  final IdScanService _scanService = IdScanService();
  late final IdVerificationService _idVerificationService;

  var selectedIdType = Rx<String?>(null);
  var frontImage = Rx<XFile?>(null);
  var backImage = Rx<XFile?>(null);
  var scannedName = Rx<String?>(null);
  var scanWarning = Rx<String?>(null);
  var orientationWarning = Rx<String?>(null);
  var backOrientationWarning = Rx<String?>(null);
  var isTypeMatch = true.obs;
  var isScanning = false.obs;
  var scannedQrCode = Rx<String?>(null);
  var scannedQrName = Rx<String?>(null);
  var qrScanWarning = Rx<String?>(null);
  var nameMatchResult = Rx<bool?>(null);

  @override
  void onInit() {
    super.onInit();
    _idVerificationService = Get.find<IdVerificationService>();
  }

  List<String> get idOptions => _service.idOptions;
  bool get bothImagesSelected => frontImage.value != null && backImage.value != null;

  void setSelectedIdType(String? idType) {
    selectedIdType.value = idType;
    // Clear uploaded images and reset scanning state when ID type changes
    frontImage.value = null;
    backImage.value = null;
    scannedName.value = null;
    scanWarning.value = null;
    scannedQrCode.value = null;
    scannedQrName.value = null;
    qrScanWarning.value = null;
    orientationWarning.value = null;
    backOrientationWarning.value = null;
    nameMatchResult.value = null;

    // Also clear the verification service's scanned name
    try {
      _idVerificationService.clearScannedName();
    } catch (_) {}

    // If selected type is driver's license, there's no QR comparison step
    final norm = (idType ?? '').toLowerCase();
    if (norm.contains('driver')) {
      // mark as matched by default so driver flows can continue after uploads
      nameMatchResult.value = true;
    }
  }

  Future<void> pickImage(bool isFront) async {
    final XFile? file = await _service.pickImage();
    if (file == null) return;
    // Clear previous match result while the user is picking a new image
    nameMatchResult.value = null;
    if (isFront) {
      final isOrientationValid = await _service.isOrientationValidForIdType(
        file,
        selectedIdType.value,
      );

      orientationWarning.value = isOrientationValid
          ? null
          : 'You can keep the phone in portrait. Just make sure the ID itself is horizontal and readable in the frame.';
      frontImage.value = file;
      // Scan front image to extract name
      await _scanAndExtractName(file);
    } else {
      final isBackOrientationValid = await _service.isOrientationValidForIdType(
        file,
        selectedIdType.value,
      );

      backOrientationWarning.value = isBackOrientationValid
          ? null
          : 'For the back side, keep the ID itself in landscape so the barcode and details stay readable.';
      backImage.value = file;
      // Scan back image for QR code
      await _scanQrCodeFromBackImage(file);
    }
  }

  Future<void> _scanAndExtractName(XFile imageFile) async {
    isScanning.value = true;
    try {
      IdScanResult result;
      final norm = (selectedIdType.value ?? '').toLowerCase();
      if (norm.contains('national') || norm.contains('philsys')) {
        result = await _scanService.extractNameFromPhilSysImage(imageFile);
      } else if (norm.contains('driver')) {
        result = await _scanService.extractNameFromDriversLicenseImage(imageFile);
      } else {
        result = await _scanService.extractNameFromIdImage(imageFile, idType: selectedIdType.value);
      }

      scannedName.value = result.extractedName;
      scanWarning.value = result.warningMessage;
      isTypeMatch.value = result.matchesSelectedType;

      if (result.extractedName != null && result.extractedName!.isNotEmpty && result.matchesSelectedType) {
        _idVerificationService.setScannedName(result.extractedName);
      } else {
        _idVerificationService.clearScannedName();
      }

      // Recompute match (if possible) after front scan
      _recomputeNameMatch();
    } catch (e) {
      print('Error during ID scan: $e');
      scanWarning.value = 'An error occurred while scanning the ID.';
      isTypeMatch.value = false;
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> _scanQrCodeFromBackImage(XFile imageFile) async {
    isScanning.value = true;
    try {
      final norm = (selectedIdType.value ?? '').toLowerCase();
      // Only attempt QR parsing for PhilSys / National ID cards
      if (!(norm.contains('national') || norm.contains('philsys'))) {
        // For driver's license or unknown types, do not attempt QR scan
        scannedQrCode.value = null;
        scannedQrName.value = null;
        qrScanWarning.value = null;
        // For driver license we already set nameMatchResult=true in setSelectedIdType
        return;
      }
      print('Starting QR code scan for back image...');
      final rawQrContent = await _scanService.readQrRaw(imageFile);

      if (rawQrContent != null && rawQrContent.isNotEmpty) {
        print('QR code found: $rawQrContent');
        scannedQrCode.value = rawQrContent;
        
        // Extract name from QR content
        final extractedQrName = _scanService.extractNameFromQrRawContent(rawQrContent);
        scannedQrName.value = extractedQrName;
        
        if (extractedQrName != null && extractedQrName.isNotEmpty) {
          print('QR name extracted: $extractedQrName');
          qrScanWarning.value = null;
          
          // Compare with front image name if available
          // Recompute match using helper to avoid race conditions
          _recomputeNameMatch();
        } else {
          print('QR detected but no name extracted');
          qrScanWarning.value = 'QR code found but couldn\'t extract name. The barcode format may not be supported.';
        }
      } else {
        print('No QR code detected');
        qrScanWarning.value = 'No QR code detected on the back. Ensure the barcode is clearly visible and not obstructed.';
        scannedQrCode.value = null;
        scannedQrName.value = null;
      }
    } catch (e) {
      print('Error during QR code scan: $e');
      qrScanWarning.value = 'An error occurred while scanning the QR code.';
      scannedQrCode.value = null;
      scannedQrName.value = null;
    } finally {
      isScanning.value = false;
    }
  }

  void _recomputeNameMatch() {
    if (scannedName.value != null && scannedName.value!.isNotEmpty && scannedQrName.value != null && scannedQrName.value!.isNotEmpty) {
      final namesMatch = _scanService.namesMatchApproximately(scannedName.value!, scannedQrName.value!);
      nameMatchResult.value = namesMatch;
      print('Recomputed name match: Front="${scannedName.value}" vs QR="${scannedQrName.value}" -> $namesMatch');
    } else {
      // Not enough info yet
      nameMatchResult.value = null;
    }
  }

  void resetState() {
    selectedIdType.value = null;
    frontImage.value = null;
    backImage.value = null;
    scannedName.value = null;
    scanWarning.value = null;
    orientationWarning.value = null;
    backOrientationWarning.value = null;
    scannedQrCode.value = null;
    scannedQrName.value = null;
    qrScanWarning.value = null;
    nameMatchResult.value = null;
    isTypeMatch.value = true;
    isScanning.value = false;
  }
}



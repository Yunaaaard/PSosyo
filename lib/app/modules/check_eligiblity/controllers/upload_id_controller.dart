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

  @override
  void onInit() {
    super.onInit();
    _idVerificationService = Get.find<IdVerificationService>();
  }

  List<String> get idOptions => _service.idOptions;
  bool get bothImagesSelected => frontImage.value != null && backImage.value != null;

  void setSelectedIdType(String? idType) {
    selectedIdType.value = idType;
  }

  Future<void> pickImage(bool isFront) async {
    final XFile? file = await _service.pickImage();
    if (file == null) return;
    
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
    }
  }

  Future<void> _scanAndExtractName(XFile imageFile) async {
    isScanning.value = true;
    try {
      final result = await _scanService.extractNameFromIdImage(
        imageFile,
        idType: selectedIdType.value,
      );

      scannedName.value = result.extractedName;
      scanWarning.value = result.warningMessage;
      isTypeMatch.value = result.matchesSelectedType;

      if (result.extractedName != null && result.extractedName!.isNotEmpty && result.matchesSelectedType) {
        _idVerificationService.setScannedName(result.extractedName);
      } else {
        _idVerificationService.clearScannedName();
      }
    } catch (e) {
      print('Error during ID scan: $e');
      scanWarning.value = 'An error occurred while scanning the ID.';
      isTypeMatch.value = false;
    } finally {
      isScanning.value = false;
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
    isTypeMatch.value = true;
    isScanning.value = false;
  }
}



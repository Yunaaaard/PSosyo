import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_sosyo/app/services/upload_id_service.dart';

class UploadIdController extends GetxController {
  final UploadIdService _service = UploadIdService();

  // Reactive state
  var selectedIdType = Rx<String?>(null);
  var frontImage = Rx<XFile?>(null);
  var backImage = Rx<XFile?>(null);

  // Getters for UI convenience
  List<String> get idOptions => _service.idOptions;

  bool get bothImagesSelected => frontImage.value != null && backImage.value != null;

  /// Update selected ID type
  void setSelectedIdType(String? idType) {
    selectedIdType.value = idType;
  }

  /// Pick an image for front or back
  Future<void> pickImage(bool isFront) async {
    final XFile? file = await _service.pickImage();
    if (file == null) return;
    
    if (isFront) {
      frontImage.value = file;
    } else {
      backImage.value = file;
    }
  }

  /// Reset all state (e.g., on page pop or retry)
  void resetState() {
    selectedIdType.value = null;
    frontImage.value = null;
    backImage.value = null;
  }
}

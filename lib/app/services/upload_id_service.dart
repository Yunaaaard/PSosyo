import 'package:image_picker/image_picker.dart';

class UploadIdService {
  static final UploadIdService _instance = UploadIdService._internal();

  factory UploadIdService() {
    return _instance;
  }

  UploadIdService._internal();

  final ImagePicker _picker = ImagePicker();

  /// List of available ID types
  final List<String> idOptions = [
    'National ID',
    "Driver's License",
    'Postal ID',
    'Passport',
  ];

  /// Pick an image from gallery
  Future<XFile?> pickImage({int? maxWidth, int? maxHeight}) async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: (maxWidth ?? 1600).toDouble(),
      maxHeight: (maxHeight ?? 1600).toDouble(),
    );
  }
}

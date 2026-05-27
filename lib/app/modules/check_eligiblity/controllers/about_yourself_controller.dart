import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/services/id_verification_service.dart';
import 'package:p_sosyo/app/services/user_phone_service.dart';

class AboutYourselfController extends GetxController {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  var selectedStatus = Rx<String?>(null);
  var selectedGender = Rx<String?>(null);
  var lockedGender = Rx<String?>(null);
  var isGenderLocked = false.obs;
  var isFormComplete = false.obs;

  final statusOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  late final IdVerificationService _idVerificationService;
  late final PsosyoDatabaseService _databaseService;
  late final UserPhoneService _userPhoneService;
  Worker? _nameWorker;
  Worker? _birthDateWorker;
  Worker? _genderWorker;

  @override
  void onInit() {
    super.onInit();
    _idVerificationService = Get.find<IdVerificationService>();
    _databaseService = Get.find<PsosyoDatabaseService>();
    _userPhoneService = Get.find<UserPhoneService>();

    fullnameController.addListener(_syncFormState);
    emailController.addListener(_syncFormState);
    dateOfBirthController.addListener(_syncFormState);
    addressController.addListener(_syncFormState);

    // Check if scanned name is available from ID scanning
    final scannedName = _idVerificationService.getScannedName();
    if (scannedName != null && scannedName.isNotEmpty) {
      fullnameController.text = scannedName;
    }

    final scannedBirthDate = _idVerificationService.getScannedBirthDate();
    if (scannedBirthDate != null && scannedBirthDate.isNotEmpty) {
      dateOfBirthController.text = scannedBirthDate;
    }

    _applyScannedGender(_idVerificationService.getScannedGender());

    // Keep fields in sync in case OCR finishes after this page opens.
    _nameWorker = ever<String?>(_idVerificationService.scannedName, (value) {
      if (value != null &&
          value.isNotEmpty &&
          fullnameController.text != value) {
        fullnameController.text = value;
      }
    });

    _birthDateWorker =
        ever<String?>(_idVerificationService.scannedBirthDate, (value) {
      if (value != null &&
          value.isNotEmpty &&
          dateOfBirthController.text != value) {
        dateOfBirthController.text = value;
      }
    });

    _genderWorker =
        ever<String?>(_idVerificationService.scannedGender, (value) {
      _applyScannedGender(value);
    });

    _syncFormState();
  }

  void _syncFormState() {
    isFormComplete.value = fullnameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        dateOfBirthController.text.trim().isNotEmpty &&
        selectedStatus.value != null &&
        selectedGender.value != null &&
        addressController.text.trim().isNotEmpty;
    update();
  }

  void setStatus(String? status) {
    selectedStatus.value = status;
    _syncFormState();
  }

  void setGender(String gender) {
    if (isGenderLocked.value && lockedGender.value != gender) {
      return;
    }
    selectedGender.value = gender;
    _syncFormState();
  }

  bool canSelectGender(String option) {
    if (!isGenderLocked.value) return true;
    return lockedGender.value == option;
  }

  Future<void> saveProfile() async {
    await _databaseService.saveUserProfile(
      phoneNumber: _userPhoneService.getRegisteredPhone(),
      fullName: fullnameController.text.trim(),
      email: emailController.text.trim(),
      dateOfBirth: dateOfBirthController.text.trim(),
      status: selectedStatus.value ?? '',
      gender: selectedGender.value ?? '',
      address: addressController.text.trim(),
    );
  }

  void _applyScannedGender(String? rawGender) {
    final normalized = _normalizeScannedGender(rawGender);
    if (normalized == null) {
      lockedGender.value = null;
      isGenderLocked.value = false;
      update();
      return;
    }

    lockedGender.value = normalized;
    isGenderLocked.value = true;
    selectedGender.value = normalized;
    _syncFormState();
  }

  String? _normalizeScannedGender(String? rawGender) {
    if (rawGender == null) return null;
    final value = rawGender.trim().toLowerCase();
    if (value.isEmpty) return null;
    if (value == 'm' || value == 'male') return 'Male';
    if (value == 'f' || value == 'female') return 'Female';
    return null;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateOfBirthController.text =
          '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
      _syncFormState();
    }
  }

  @override
  void onClose() {
    _nameWorker?.dispose();
    _birthDateWorker?.dispose();
    _genderWorker?.dispose();
    fullnameController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    super.onClose();
  }
}

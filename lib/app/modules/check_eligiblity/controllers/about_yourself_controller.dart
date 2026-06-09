import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/data/database/psosyo_database_service.dart';
import 'package:p_sosyo/app/data/services/id_verification_service.dart';
import 'package:p_sosyo/app/data/services/user_phone_service.dart';

class AboutYourselfController extends GetxController {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  // Separated address fields
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  var selectedStatus = Rx<String?>(null);
  var selectedGender = Rx<String?>(null);
  var lockedGender = Rx<String?>(null);
  var isGenderLocked = false.obs;
  var isFormComplete = false.obs;

  // Country and City dropdown options & states
  var selectedCountry = 'Philippines'.obs;
  var selectedCity = Rx<String?>(null);
  var citiesList = <String>[].obs;
  var isLoadingCities = false.obs;

  final countryOptions = const ['Philippines'];
  static const fallbackCities = [
    'Caloocan', 'Cebu City', 'Davao City', 'Manila', 'Quezon City',
    'Zamboanga City', 'Taguig', 'Pasig', 'Cagayan de Oro', 'Parañaque',
    'Valenzuela', 'Mandaluyong', 'Makati', 'Muntinlupa', 'Marikina',
    'Las Piñas', 'Pasay', 'Malabon', 'Navotas', 'San Juan',
    'Bacolod', 'Baguio', 'Batangas City', 'Cabanatuan', 'Calamba',
    'Cavite City', 'Dagupan', 'General Santos', 'Iligan', 'Iloilo City',
    'Imus', 'Laoag', 'Lapu-Lapu', 'Legazpi', 'Lucena', 'Mandaue',
    'Naga', 'Olongapo', 'Ormoc', 'Puerto Princesa', 'Roxas City',
    'San Fernando', 'Tacloban', 'Tagbilaran', 'Tarlac City'
  ];

  final statusOptions = const ['Single', 'Married', 'Divorced', 'Widowed'];
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
    streetController.addListener(_syncFormState);
    postalCodeController.addListener(_syncFormState);
    cityController.addListener(_syncFormState);
    countryController.addListener(_syncFormState);

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

    // Initialize default values for dropdowns
    countryController.text = 'Philippines';
    selectedCountry.value = 'Philippines';
    if (cityController.text.isNotEmpty) {
      selectedCity.value = cityController.text;
    }

    fetchCities();
    _syncFormState();
  }

  void _syncFormState() {
    final emailValid = _isValidEmail(emailController.text);
    final addressFilled = streetController.text.trim().isNotEmpty &&
        _isValidPostalCode(postalCodeController.text) &&
        cityController.text.trim().isNotEmpty &&
        countryController.text.trim().isNotEmpty;

    isFormComplete.value = fullnameController.text.trim().isNotEmpty &&
        emailValid &&
        dateOfBirthController.text.trim().isNotEmpty &&
        selectedStatus.value != null &&
        selectedGender.value != null &&
        addressFilled;
    update();
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return false;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  bool _isValidPostalCode(String value) {
    final postalCode = value.trim();
    if (postalCode.isEmpty) return false;
    return RegExp(r'^[0-9\-\s]{3,10}$').hasMatch(postalCode);
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!_isValidEmail(email)) return 'Enter a valid email';
    return null;
  }

  String? validateRequired(String? value, String label) {
    if ((value ?? '').trim().isEmpty) return '$label is required';
    return null;
  }

  String? validatePostalCode(String? value) {
    final postalCode = value?.trim() ?? '';
    if (postalCode.isEmpty) return 'Postal code is required';
    if (!_isValidPostalCode(postalCode)) return 'Enter a valid postal code';
    return null;
  }

  void setStatus(String? status) {
    selectedStatus.value = status;
    _syncFormState();
  }

  void setCity(String? city) {
    selectedCity.value = city;
    cityController.text = city ?? '';
    _syncFormState();
  }

  void setCountry(String? country) {
    selectedCountry.value = country ?? 'Philippines';
    countryController.text = country ?? 'Philippines';
    _syncFormState();
  }

  Future<void> fetchCities() async {
    isLoadingCities.value = true;
    update();
    try {
      final response = await http
          .get(Uri.parse('https://psgc.gitlab.io/api/cities-and-municipalities.json'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<String> fetchedCities =
            data.map((item) => item['name'] as String).toList();

        // Remove duplicates and sort alphabetically
        final uniqueCities = fetchedCities.toSet().toList()..sort();
        citiesList.assignAll(uniqueCities);
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e. Using fallback.');
      citiesList.assignAll(fallbackCities);
    } finally {
      // Ensure the currently selected city is in the list to avoid dropdown assertion errors
      if (cityController.text.isNotEmpty && !citiesList.contains(cityController.text)) {
        citiesList.add(cityController.text);
        citiesList.sort();
      }
      isLoadingCities.value = false;
      update();
    }
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
      street: streetController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      city: cityController.text.trim(),
      country: countryController.text.trim(),
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
    streetController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    countryController.dispose();
    super.onClose();
  }
}

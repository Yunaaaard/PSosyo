import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/services/id_verification_service.dart';

class AboutYourselfController extends GetxController {
	final TextEditingController fullnameController = TextEditingController();
	final TextEditingController emailController = TextEditingController();
	final TextEditingController dateOfBirthController = TextEditingController();
	final TextEditingController addressController = TextEditingController();

	var selectedStatus = Rx<String?>(null);
	var selectedGender = Rx<String?>(null);
	var isFormComplete = false.obs;

	final statusOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
	late final IdVerificationService _idVerificationService;

	@override
	void onInit() {
		super.onInit();
		_idVerificationService = Get.find<IdVerificationService>();
		
		fullnameController.addListener(_syncFormState);
		emailController.addListener(_syncFormState);
		dateOfBirthController.addListener(_syncFormState);
		addressController.addListener(_syncFormState);
		
		// Check if scanned name is available from ID scanning
		final scannedName = _idVerificationService.getScannedName();
		if (scannedName != null && scannedName.isNotEmpty) {
			fullnameController.text = scannedName;
		}
		
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
		selectedGender.value = gender;
		_syncFormState();
	}

	Future<void> selectDate(BuildContext context) async {
		final DateTime? picked = await showDatePicker(
			context: context,
			initialDate: DateTime.now(),
			firstDate: DateTime(1900),
			lastDate: DateTime.now(),
		);

		if (picked != null) {
			dateOfBirthController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
			_syncFormState();
		}
	}

	@override
	void onClose() {
		fullnameController.dispose();
		emailController.dispose();
		dateOfBirthController.dispose();
		addressController.dispose();
		super.onClose();
	}
}

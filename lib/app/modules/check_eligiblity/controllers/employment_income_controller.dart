import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EmploymentIncomeController extends GetxController {
	final TextEditingController sourceOfIncomeController = TextEditingController();
	final TextEditingController monthlyIncomeController = TextEditingController();
	final TextEditingController incomeTaxController = TextEditingController();
	final TextEditingController employerNameController = TextEditingController();
	final TextEditingController yearsOfEmploymentController = TextEditingController();

	var receiptFiles = <XFile>[].obs;
	var isFormComplete = false.obs;

	final ImagePicker _picker = ImagePicker();

	@override
	void onInit() {
		super.onInit();
		sourceOfIncomeController.addListener(_syncFormState);
		monthlyIncomeController.addListener(_syncFormState);
		incomeTaxController.addListener(_syncFormState);
		employerNameController.addListener(_syncFormState);
		yearsOfEmploymentController.addListener(_syncFormState);
		_syncFormState();
	}

	Future<void> pickReceipt() async {
		if (receiptFiles.length >= 4) {
			Get.snackbar(
				'Limit reached',
				'You can upload up to 4 receipt photos only.',
				snackPosition: SnackPosition.BOTTOM,
				margin: const EdgeInsets.all(16),
			);
			return;
		}

		final List<XFile> files = await _picker.pickMultiImage();
		if (files.isEmpty) {
			return;
		}

		final remainingSlots = 4 - receiptFiles.length;
		receiptFiles.addAll(files.take(remainingSlots));
		_syncFormState();
	}

	void removeReceiptAt(int index) {
		if (index < 0 || index >= receiptFiles.length) {
			return;
		}

		receiptFiles.removeAt(index);
		_syncFormState();
	}

	void _syncFormState() {
		isFormComplete.value = sourceOfIncomeController.text.trim().isNotEmpty &&
			monthlyIncomeController.text.trim().isNotEmpty &&
			incomeTaxController.text.trim().isNotEmpty &&
			employerNameController.text.trim().isNotEmpty &&
			yearsOfEmploymentController.text.trim().isNotEmpty &&
			receiptFiles.isNotEmpty;
		update();
	}

	@override
	void onClose() {
		sourceOfIncomeController.dispose();
		monthlyIncomeController.dispose();
		incomeTaxController.dispose();
		employerNameController.dispose();
		yearsOfEmploymentController.dispose();
		receiptFiles.clear();
		super.onClose();
	}
}
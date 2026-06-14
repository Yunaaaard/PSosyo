import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';

class EmploymentIncomeController extends GetxController {
	final TextEditingController desiredLoanAmountController = TextEditingController();
	final TextEditingController monthlyRevenueController = TextEditingController();
	final TextEditingController storeNameController = TextEditingController();
	final TextEditingController yearsInBusinessController = TextEditingController();

	var receiptFiles = <XFile>[].obs;
	var isFormComplete = false.obs;

	final ImagePicker _picker = ImagePicker();

	@override
	void onInit() {
		super.onInit();
		desiredLoanAmountController.addListener(_syncFormState);
		monthlyRevenueController.addListener(_syncFormState);
		storeNameController.addListener(_syncFormState);
		yearsInBusinessController.addListener(_syncFormState);
		_syncFormState();
	}

	Future<void> pickReceipt() async {
		if (receiptFiles.length >= 4) {
			AppSnackbar.show(
				title: 'Limit reached',
				message: 'You can upload up to 4 receipt photos only.',
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
		isFormComplete.value = desiredLoanAmountController.text.trim().isNotEmpty &&
			monthlyRevenueController.text.trim().isNotEmpty &&
			storeNameController.text.trim().isNotEmpty &&
			yearsInBusinessController.text.trim().isNotEmpty &&
			receiptFiles.isNotEmpty;
		update();
	}

	@override
	void onClose() {
		desiredLoanAmountController.dispose();
		monthlyRevenueController.dispose();
		storeNameController.dispose();
		yearsInBusinessController.dispose();
		receiptFiles.clear();
		super.onClose();
	}
}
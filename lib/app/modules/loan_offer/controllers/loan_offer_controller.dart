import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/services/user_phone_service.dart';
import 'package:p_sosyo/app/widgets/loan_agreement_sheet.dart';

class LoanOfferController extends GetxController {
  final isAgreementAccepted = false.obs;

  void markAgreementAccepted() {
    isAgreementAccepted.value = true;
  }

  void openAgreementSheet() {
    Get.bottomSheet(
      LoanAgreementSheet(onAgreementAccepted: markAgreementAccepted),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  void openLoanOfferOtp() {
    if (!isAgreementAccepted.value) return;

    final phone = Get.find<UserPhoneService>().getRegisteredPhone();

    Get.toNamed(
      AppRoutes.verifyOtp,
      arguments: {
        'flow': 'loanOfferESign',
        'phone': phone,
      },
    );
  }
}

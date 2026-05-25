import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/loan_offer/controllers/loan_offer_controller.dart';

class LoanOfferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoanOfferController>(() => LoanOfferController());
  }
}

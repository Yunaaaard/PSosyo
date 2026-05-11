import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/dashboard_page/pages/psosyo_eligiblity_page.dart';

class DashboardController extends GetxController {
  // Carousel data
  late RxList<String> carouselImages;

  // Stats data
  late RxString totalOrderedValue;
  late RxString totalProducts;

  // Brand categories data
  late RxList<Map<String, String>> brandCategories;

  @override
  void onInit() {
    super.onInit();
    _initializeCarousel();
    _initializeStats();
    _initializeBrandCategories();
  }

  void _initializeCarousel() {
    carouselImages = RxList<String>([
      'assets/images/cdo-card.png',
      'assets/images/monde-card.png',
      'assets/images/nestle-card.png',
    ]);
  }

  void _initializeStats() {
    totalOrderedValue = RxString('0,000.00');
    totalProducts = RxString('2,028 SKU\'s');
  }

  void _initializeBrandCategories() {
    brandCategories = RxList<Map<String, String>>([
      {
        'title': 'Nestle',
        'imageCard': 'assets/images/nestle-card.png',
        'logo': 'assets/images/nestle-sample-logo.png',
      },
      {
        'title': 'Monde Nissin',
        'imageCard': 'assets/images/monde-card.png',
        'logo': 'assets/images/monde-sample-logo.png',
      },
      {
        'title': 'CDO',
        'imageCard': 'assets/images/cdo-card.png',
        'logo': 'assets/images/cdo-sample-logo.png',
      },
    ]);
  }

  // Methods to update data if needed
  void updateOrderedAmount(String amount) {
    totalOrderedValue.value = amount;
  }

  void updateProductCount(String count) {
    totalProducts.value = count;
  }

  void openPsosyoEligibility() {
    Get.to(() => const PsosyoEligibilityPage());
  }
}

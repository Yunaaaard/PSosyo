import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/widgets/custom_app_bar.dart';
import 'package:p_sosyo/app/widgets/custom_navbar.dart';
import 'package:p_sosyo/app/widgets/carousel_widget.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/modules/dashboard_page/controller/dashboard_controller.dart';

class InitialDashboard extends StatelessWidget {
  const InitialDashboard({Key? key}) : super(key: key);

  DashboardController get controller =>
      Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarousel(context),
              const SizedBox(height: 15),
              _buildStatsCard(context),
                const SizedBox(height: 18),
                _buildBrandCategoriesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return CarouselWidget(images: controller.carouselImages);
  }

  Widget _buildStatsCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Ordered Value',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => PesoFormatter.buildPesoText(
                            amount: controller.totalOrderedValue.value,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          )),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Products',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                            controller.totalProducts.value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        _buildPsosyoButton(context),
      ],
    );
  }

  Widget _buildPsosyoButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.openPsosyoEligibility,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF6533E7),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/psosyo-icon-button.svg',
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Psosyo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BRAND CATEGORIES',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF69707D),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        ...controller.brandCategories.map(
          (category) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBrandCategoryCard(
              title: category['title'] ?? '',
              imagePath: category['imageCard'] ?? '',
              logoPath: category['logo'] ?? '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandCategoryCard({
    required String title,
    required String imagePath,
    required String logoPath,
  }) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.10),
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 100,
              right: 12,
              bottom: 12,
              height: 72,
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ordered Amount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Product Count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PesoFormatter.buildPesoText(
                        amount: '3,000.00',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '12',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

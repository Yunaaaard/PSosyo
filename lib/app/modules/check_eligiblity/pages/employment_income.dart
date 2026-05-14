import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/employment_income_controller.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/utils/peso_formatter.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/basic_info_appbar.dart';

class EmploymentIncomePage extends StatelessWidget {
  const EmploymentIncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmploymentIncomeController>(
      init: EmploymentIncomeController(),
      builder: (controller) {
        final colors = Theme.of(context).extension<PsosyoThemeColors>() ?? AppColors.psosyo;

        return Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BasicInfoAppBar(),
                  const SizedBox(height: 24),
                  Text(
                    'Step 4 of 4',
                    style: TextStyle(
                      color: colors.darkText,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Stack(
                      children: [
                        Container(height: 13, color: const Color(0xFFE9E3FF)),
                        FractionallySizedBox(
                          widthFactor: 1.0,
                          child: Container(height: 13, color: colors.primaryPurple),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Employment and Income',
                    style: TextStyle(
                      color: colors.darkText,
                      fontSize: 25,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please provide your legal information as it appears on your government ID to help us verify your identity.',
                    style: TextStyle(
                      color: colors.titleGrey,
                      fontSize: 18,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(colors, 'Source of Income'),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: controller.sourceOfIncomeController,
                            colors: colors,
                          ),
                          const SizedBox(height: 24),
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                color: colors.darkText,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                const TextSpan(text: 'Monthly Income ('),
                                PesoFormatter.buildPesoSymbolSpan(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: colors.darkText,
                                ),
                                const TextSpan(text: ')'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: controller.monthlyIncomeController,
                            colors: colors,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          _buildFieldLabel(colors, 'Income Tax'),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: controller.incomeTaxController,
                            colors: colors,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          _buildFieldLabel(colors, 'Employer Name'),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: controller.employerNameController,
                            colors: colors,
                          ),
                          const SizedBox(height: 24),
                          _buildFieldLabel(colors, 'Years of Employment'),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: controller.yearsOfEmploymentController,
                            colors: colors,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 18),
                          DottedBorder(
                            color: const Color(0xFFC4C7CF),
                            strokeWidth: 1.8,
                            dashPattern: const [8, 6],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(16),
                            child: InkWell(
                              onTap: controller.pickReceipt,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 170),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                child: Obx(
                                  () {
                                    final receiptFiles = controller.receiptFiles;

                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (receiptFiles.isEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(color: const Color(0xFFA9ADB8), width: 1.5),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.cloud_upload_outlined, color: colors.titleGrey),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Upload',
                                                  style: TextStyle(
                                                    color: colors.titleGrey,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          SizedBox(
                                            height: 92,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: receiptFiles.length,
                                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                                              itemBuilder: (context, index) {
                                                final receipt = receiptFiles[index];

                                                return Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.file(
                                                        File(receipt.path),
                                                        fit: BoxFit.cover,
                                                        width: 92,
                                                        height: 92,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: -8,
                                                      top: -8,
                                                      child: GestureDetector(
                                                        onTap: () => controller.removeReceiptAt(index),
                                                        child: Container(
                                                          width: 24,
                                                          height: 24,
                                                          decoration: BoxDecoration(
                                                            color: colors.darkText,
                                                            shape: BoxShape.circle,
                                                            border: Border.all(color: Colors.white, width: 2),
                                                          ),
                                                          child: const Icon(
                                                            Icons.close,
                                                            size: 14,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        const SizedBox(height: 14),
                                        Text(
                                          receiptFiles.isEmpty
                                              ? 'Attach receipt of the last 4 purchases from saleman. PNG, JPG or PDF up to 10MB'
                                              : 'Selected ${receiptFiles.length} of 4 receipt photos. Tap upload again to add more.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: colors.titleGrey,
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              'Your data is encrypted and only used for identity verification purposes.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.titleGrey,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () {
                      final canContinue = controller.isFormComplete.value;
                      return ElevatedButton(
                        style: canContinue
                            ? AppThemes.primaryButtonStyle
                            : AppThemes.unaccessibleButtonStyle,
                        onPressed: canContinue
                            ? () => Get.offAllNamed(AppRoutes.verificationProcess)
                            : null,
                        child: const Center(child: Text('Continue')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(PsosyoThemeColors colors, String text) {
    return Text(
      text,
      style: TextStyle(
        color: colors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required PsosyoThemeColors colors,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: colors.titleGrey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE3E5EA), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE3E5EA), width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: colors.darkText, fontSize: 18),
    );
  }
}
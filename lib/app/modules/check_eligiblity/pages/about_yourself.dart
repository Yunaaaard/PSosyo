import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/controllers/about_yourself_controller.dart';
import 'package:p_sosyo/app/routes/app_routes.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import 'package:p_sosyo/app/widgets/basic_info_appbar.dart';

class AboutYourselfPage extends StatelessWidget {
  const AboutYourselfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AboutYourselfController>(
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
                    'Step 3 of 4',
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
                        Container(
                          height: 13,
                          color: const Color(0xFFE9E3FF),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.75,
                          child: Container(
                            height: 13,
                            color: colors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Tell us about yourself',
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
                  const SizedBox(height: 34),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fullname
                          Text(
                            'Fullname',
                            style: TextStyle(
                              color: colors.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller.fullnameController,
                            readOnly: true,
                            showCursor: false,
                            decoration: InputDecoration(
                              hintText: 'Fetched from your ID',
                              hintStyle: TextStyle(color: colors.titleGrey),
                              filled: true,
                              fillColor: const Color(0xFFF7F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE3E5EA), width: 1.2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE3E5EA), width: 1.2),
                              ),
                              suffixIcon: Icon(Icons.lock_outline, color: colors.titleGrey, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            style: TextStyle(color: colors.darkText, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This name is taken from the uploaded ID and cannot be edited here.',
                            style: TextStyle(
                              color: colors.titleGrey,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Address
                          Text(
                            'Email Address',
                            style: TextStyle(
                              color: colors.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              hintText: 'example@email.com',
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
                          ),
                          const SizedBox(height: 24),

                          // Date of Birth
                          Text(
                            'Date of Birth',
                            style: TextStyle(
                              color: colors.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller.dateOfBirthController,
                            readOnly: true,
                            onTap: () => controller.selectDate(context),
                            decoration: InputDecoration(
                              hintText: 'Enter Date of Birth',
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
                              suffixIcon: Icon(Icons.calendar_today, color: colors.titleGrey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            style: TextStyle(color: colors.darkText, fontSize: 18),
                          ),
                          const SizedBox(height: 24),

                          // Status dropdown
                          Text(
                            'Status',
                            style: TextStyle(
                              color: colors.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE3E5EA), width: 1.2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: controller.selectedStatus.value,
                                hint: Text(
                                  'Select Status',
                                  style: TextStyle(color: colors.titleGrey, fontSize: 18),
                                ),
                                items: controller.statusOptions
                                    .map((option) => DropdownMenuItem(
                                          value: option,
                                          child: Text(option, style: const TextStyle(fontSize: 18)),
                                        ))
                                    .toList(),
                                onChanged: controller.setStatus,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.titleGrey, size: 24),
                                style: TextStyle(color: colors.darkText, fontSize: 18, fontFamily: 'Poppins'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Gender selection
                          Text(
                            'Gender',
                            style: TextStyle(
                              color: colors.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // ── Fix: each Expanded was missing its closing `)` ──
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.setGender('Male'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: controller.selectedGender.value == 'Male'
                                            ? colors.primaryPurple
                                            : const Color(0xFFE3E5EA),
                                        width: 1.5,
                                      ),
                                      color: controller.selectedGender.value == 'Male'
                                          ? colors.lightPurple
                                          : Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Male',
                                        style: TextStyle(
                                          color: controller.selectedGender.value == 'Male'
                                              ? colors.primaryPurple
                                              : colors.titleGrey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.setGender('Female'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: controller.selectedGender.value == 'Female'
                                            ? colors.primaryPurple
                                            : const Color(0xFFE3E5EA),
                                        width: 1.5,
                                      ),
                                      color: controller.selectedGender.value == 'Female'
                                          ? colors.lightPurple
                                          : Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Female',
                                        style: TextStyle(
                                          color: controller.selectedGender.value == 'Female'
                                              ? colors.primaryPurple
                                              : colors.titleGrey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.setGender('Other'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: controller.selectedGender.value == 'Other'
                                            ? colors.primaryPurple
                                            : const Color(0xFFE3E5EA),
                                        width: 1.5,
                                      ),
                                      color: controller.selectedGender.value == 'Other'
                                          ? colors.lightPurple
                                          : Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Other',
                                        style: TextStyle(
                                          color: controller.selectedGender.value == 'Other'
                                              ? colors.primaryPurple
                                              : colors.titleGrey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Permanent Address
                          Text(
                            'Permanent Address',
                            style: TextStyle(
                              color: colors.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller.addressController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Enter your permanent address',
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
                          ),
                          const SizedBox(height: 24),

                          // Privacy notice
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
                            ? () => Get.toNamed(AppRoutes.employmentIncome)
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
}
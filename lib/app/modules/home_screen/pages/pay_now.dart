import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:p_sosyo/app/modules/home_screen/controllers/home_controller.dart';
import 'package:p_sosyo/app/utils/themes/theme_colors.dart';
import 'package:p_sosyo/app/utils/pay_now_utils.dart';
import 'package:p_sosyo/app/widgets/pay_now_widgets.dart';
import 'package:p_sosyo/app/widgets/psosyo_app_bar.dart';

const double _menuHorizontalPadding = 1.0;
const double _qrSize = 240.0;
class PayNowPage extends StatefulWidget {
  const PayNowPage({super.key});

  @override
  State<PayNowPage> createState() => _PayNowPageState();
}

class _PayNowPageState extends State<PayNowPage> {
  late final HomeController controller;
  late final TextEditingController _referenceController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    _referenceController = TextEditingController(text: controller.paymentReference.value);
    _phoneController = TextEditingController(text: controller.phoneNumber.value);

    // Keep controllers in sync with controller observables
    ever(controller.paymentReference, (val) {
      final text = (val ?? '').toString();
      if (_referenceController.text != text) {
        _referenceController.text = text;
      }
    });
    ever(controller.phoneNumber, (val) {
      final text = (val ?? '').toString();
      if (_phoneController.text != text) {
        _phoneController.text = text;
      }
    });

    _referenceController.addListener(() {
      if (controller.paymentReference.value != _referenceController.text) {
        controller.updateReference(_referenceController.text);
      }
    });

    _phoneController.addListener(() {
      if (controller.phoneNumber.value != _phoneController.text) {
        controller.updatePhoneNumber(_phoneController.text);
      }
    });
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      resizeToAvoidBottomInset: false,
      appBar: const PsosyoAppBar(
        title: 'Payment Method',
        titleColor: Color(0xFF4B4F57),
        iconColor: Color(0xFFC7CCD4),
        titleFontSize: 20,
        height: 70,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel(label: 'Reference Number'),
                const SizedBox(height: 5),
                Obx(
                  () => FieldShell(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _referenceController,
                            readOnly: controller.useAutoReference.value,
                            decoration: kBaseDecoration.copyWith(
                              hintText: 'Input Text',
                              hintStyle: kHintTextStyle,
                            ),
                            style: kInputTextStyle,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Auto',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF8E94A0),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Transform.scale(
                          scale: 0.92,
                          child: Checkbox(
                            value: controller.useAutoReference.value,
                            onChanged: (value) {
                              controller.toggleAutoReference(value ?? false);
                            },
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFD8DBE2),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SectionLabel(label: 'Phone Number'),
                const SizedBox(height: 5),
                Obx(
                  () => FieldShell(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            readOnly: controller.useAutoPhone.value,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            decoration: kBaseDecoration.copyWith(
                              hintText: controller.useAutoPhone.value
                                  ? 'Auto-filled from profile'
                                  : 'Enter 11-digit phone number',
                              hintStyle: kHintTextStyle,
                              suffixText: '${controller.phoneNumber.value.length}/11',
                              suffixStyle: kHintTextStyle,
                            ),
                            style: kInputTextStyle,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Auto',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF8E94A0),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Transform.scale(
                          scale: 0.92,
                          child: Checkbox(
                            value: controller.useAutoPhone.value,
                            onChanged: (value) {
                              controller.toggleAutoPhone(value ?? false);
                            },
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFD8DBE2),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SectionLabel(label: 'Remarks'),
                const SizedBox(height: 5),
                FieldShell(
                  child: Builder(
                    builder: (menuContext) {
                      return Obx(() {
                        final selectedRemark = controller.remarksValue.value;

                        return InkWell(
                          onTap: () async {
                            final RenderBox box = menuContext.findRenderObject() as RenderBox;
                            final Offset position = box.localToGlobal(Offset.zero);
                            final Size screen = MediaQuery.of(menuContext).size;

                            final selected = await showMenu<String>(
                              context: menuContext,
                              position: RelativeRect.fromLTRB(
                                position.dx,
                                position.dy + box.size.height,
                                screen.width - (position.dx + box.size.width),
                                0,
                              ),
                              items: controller.remarksOptions.map((option) {
                                return PopupMenuItem<String>(
                                  value: option,
                                  child: SizedBox(
                                    width: box.size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: _menuHorizontalPadding),
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2F333A),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              color: Colors.white,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            );

                            if (selected != null) {
                              controller.updateRemarks(selected);
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedRemark.isEmpty
                                        ? 'Choose preferred remarks'
                                        : selectedRemark,
                                    style: selectedRemark.isEmpty ? kHintTextStyle : kInputTextStyle,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF2F333A),
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const SectionLabel(label: 'Payment Method'),
                const SizedBox(height: 5),
                FieldShell(
                  child: Builder(
                    builder: (menuContext) {
                      return Obx(() {
                        final selectedPayment = controller.selectedPaymentType.value;

                        return InkWell(
                          onTap: () async {
                            final RenderBox box = menuContext.findRenderObject() as RenderBox;
                            final Offset position = box.localToGlobal(Offset.zero);
                            final Size screen = MediaQuery.of(menuContext).size;
                            final selected = await showMenu<String>(
                              context: menuContext,
                              position: RelativeRect.fromLTRB(
                                position.dx,
                                position.dy + box.size.height,
                                screen.width - (position.dx + box.size.width),
                                0,
                              ),
                              items: controller.paymentTypeOptions.map((option) {
                                return PopupMenuItem<String>(
                                  value: option,
                                  child: SizedBox(
                                    width: box.size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: _menuHorizontalPadding),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            assetPathForOption(option),
                                            width: 22,
                                            height: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            option,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2F333A),
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              color: Colors.white,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            );

                            if (selected != null) {
                              controller.updatePaymentType(selected);
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                if (selectedPayment.isNotEmpty)
                                  SvgPicture.asset(
                                    assetPathForOption(selectedPayment),
                                    width: 20,
                                    height: 20,
                                  )
                                else
                                  const Icon(
                                    Icons.payments_outlined,
                                    color: Color(0xFFB1B6C1),
                                    size: 20,
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedPayment.isEmpty
                                        ? 'Choose payment method'
                                        : selectedPayment,
                                    style: selectedPayment.isEmpty ? kHintTextStyle : kInputTextStyle,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFFB1B6C1),
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Obx(
                  () {
                    final paymentType = controller.selectedPaymentType.value.trim();
                    if (paymentType.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    if (paymentType.toLowerCase() == 'cash') {
                      return SummaryCard(
                        title: 'Loan Balance',
                        amount: controller.remainingBalance,
                        subtitle: 'Selected loan: ${controller.loanId}',
                        qrWidget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.payments_outlined,
                              size: 72,
                              color: Color(0xFF6B3DF0),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Cash payment selected',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111111),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No QR code is required for cash payments.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9AA0AC),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final reference = _referenceController.text.trim();
                    final phone = _phoneController.text.trim();
                    final remarks = controller.remarksValue.value.trim();

                    final payload = buildPayNowPayloadJson(
                      referenceId: reference,
                      paymentType: paymentType,
                      remarks: remarks,
                      loanId: controller.loanId,
                      distributor: controller.principalName,
                      phoneNumber: phone,
                      formattedAmount: controller.remainingBalance,
                      customerName: controller.displayUserName,
                    );

                    return SummaryCard(
                      title: 'Loan Balance',
                      amount: controller.remainingBalance,
                      subtitle: 'Selected loan: ${controller.loanId}',
                      qrWidget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Please Scan Here!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Scan this qr code to pay using $paymentType',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9AA0AC),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 19),
                          QrImageView(
                            data: payload,
                            version: QrVersions.auto,
                            size: _qrSize,
                            gapless: true,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF111111),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 18),
        child: SizedBox(
          height: 66,
          child: ElevatedButton(
            onPressed: controller.submitPayNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            child: const Text('Pay Now'),
          ),
        ),
      ),
    );
  }
}
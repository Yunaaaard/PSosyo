import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_sosyo/app/core/utils/peso_formatter.dart';

class ReceiptOcrDialog extends StatelessWidget {
  const ReceiptOcrDialog({
    super.key,
    required this.referenceNumber,
    required this.phoneNumber,
    required this.amountText,
    required this.isSuccess,
    required this.remarksValue,
    required this.paymentTypeValue,
    required this.remarksOptions,
    required this.paymentTypeOptions,
    required this.onRemarkTap,
    required this.onPaymentTypeTap,
    required this.onSubmit,
    this.onRetry,
    this.errorMessage,
  });

  final String? referenceNumber;
  final String? phoneNumber;
  final String? amountText;
  final bool isSuccess;
  final RxString remarksValue;
  final RxString paymentTypeValue;
  final List<String> remarksOptions;
  final List<String> paymentTypeOptions;
  final VoidCallback onRemarkTap;
  final VoidCallback onPaymentTypeTap;
  final VoidCallback onSubmit;
  final VoidCallback? onRetry;
  final String? errorMessage;

  static Future<void> show(
    BuildContext context, {
    required String? referenceNumber,
    required String? phoneNumber,
    required String? amountText,
    required bool isSuccess,
    required RxString remarksValue,
    required RxString paymentTypeValue,
    required List<String> remarksOptions,
    required List<String> paymentTypeOptions,
    required VoidCallback onRemarkTap,
    required VoidCallback onPaymentTypeTap,
    required VoidCallback onSubmit,
    VoidCallback? onRetry,
    String? errorMessage,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ReceiptOcrDialog(
          referenceNumber: referenceNumber,
          phoneNumber: phoneNumber,
          amountText: amountText,
          isSuccess: isSuccess,
          remarksValue: remarksValue,
          paymentTypeValue: paymentTypeValue,
          remarksOptions: remarksOptions,
          paymentTypeOptions: paymentTypeOptions,
          onRemarkTap: onRemarkTap,
          onPaymentTypeTap: onPaymentTypeTap,
          onSubmit: onSubmit,
          onRetry: onRetry,
          errorMessage: errorMessage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Obx(() {
        final hasSelections = paymentTypeValue.value.isNotEmpty && remarksValue.value.isNotEmpty;
        // OCR must have extracted reference number, phone number, and amount for Pay Now to be available
        final hasRequiredOcrData = referenceNumber != null && referenceNumber!.isNotEmpty &&
            phoneNumber != null && phoneNumber!.isNotEmpty &&
            amountText != null && amountText!.isNotEmpty;
        final canProceed = hasSelections && isSuccess && hasRequiredOcrData;
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                      isSuccess ? const Color(0xFFEAF1FF) : const Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.receipt_long_rounded : Icons.info_outline_rounded,
                  color: isSuccess ? const Color(0xFF2E5DC8) : const Color(0xFFEA4335),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess ? 'Receipt details detected' : 'Receipt text not recognized',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSuccess
                    ? 'Ref No., Phone Number, and Total Amount Sent from the GCash receipt were read.'
                    : (errorMessage?.trim().isNotEmpty == true
                        ? errorMessage!
                        : 'Make sure the receipt is clear and includes Ref No., Phone Number, and Total Amount Sent.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF6D7480),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              if (referenceNumber != null) ...[
                ReceiptDetailRow(label: 'Ref No.', value: referenceNumber),
                const SizedBox(height: 10),
              ],
              if (phoneNumber != null) ...[
                ReceiptDetailRow(label: 'Phone Number', value: phoneNumber),
                const SizedBox(height: 10),
              ],
              if (amountText != null) ...[
                ReceiptDetailRow(
                  label: 'Total Amount Sent',
                  valueWidget: PesoFormatter.buildPesoText(
                    amount: amountText!,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2430),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              ReceiptSelectionField(
                label: 'Remarks',
                value: remarksValue.value.isEmpty ? 'Select remarks' : remarksValue.value,
                isSelected: remarksValue.value.isNotEmpty,
                onTap: onRemarkTap,
              ),
              const SizedBox(height: 10),
              ReceiptSelectionField(
                label: 'Payment Method',
                value: paymentTypeValue.value.isEmpty
                    ? 'Select payment method'
                    : paymentTypeValue.value,
                isSelected: paymentTypeValue.value.isNotEmpty,
                onTap: onPaymentTypeTap,
              ),
              const SizedBox(height: 16),
              if (!isSuccess || !hasRequiredOcrData) ...[
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    !isSuccess
                        ? 'Receipt could not be read. Please retry.'
                        : 'Missing receipt data (Ref No., Phone Number, or Amount). Please retry.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEA4335),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry != null
                        ? () {
                            Navigator.of(context).pop();
                            onRetry!();
                          }
                        : () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F3FA),
                      foregroundColor: const Color(0xFF2E5DC8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Retry Capture / Upload'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: canProceed ? 1.0 : 0.45,
                  child: ElevatedButton(
                    onPressed: canProceed ? onSubmit : null,
                    child: const Text('Pay Now'),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ReceiptSelectionField extends StatelessWidget {
  const ReceiptSelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E8EF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6D7480),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color:
                      isSelected ? const Color(0xFF1F2430) : const Color(0xFF9AA0AC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptDetailRow extends StatelessWidget {
  const ReceiptDetailRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E8EF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6D7480),
            ),
          ),
          Flexible(
            child: valueWidget ??
                Text(
                  value ?? '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

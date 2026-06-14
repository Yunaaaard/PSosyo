import 'package:flutter/material.dart';

class ScanSuccessReceiptInfoRow extends StatelessWidget {
  const ScanSuccessReceiptInfoRow({
    required this.label,
    required this.value,
    required this.scale,
    super.key,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100 * scale,
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF8A8D91),
              fontSize: 17 * scale,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: const Color(0xFFC8D1D9),
              fontSize: 17 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
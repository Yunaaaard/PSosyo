import 'package:flutter/material.dart';

class PesoFormatter {
  static TextSpan buildPesoSymbolSpan({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return TextSpan(
      text: '₱',
      style: TextStyle(
        fontFamily: 'Arial',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  static Widget buildPesoText({
    required String amount,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '₱',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ],
    );
  }

  static TextSpan buildPesoTextSpan({
    required String amount,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return TextSpan(
      children: [
        buildPesoSymbolSpan(fontSize: fontSize, fontWeight: fontWeight, color: color),
        const TextSpan(text: ' '),
        TextSpan(
          text: amount,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ],
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';

const TextStyle kInputTextStyle = TextStyle(
  fontSize: 18,
  color: Color(0xFF2F333A),
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);

const TextStyle kHintTextStyle = TextStyle(
  fontSize: 18,
  color: Color(0xFF9AA0AC),
  fontWeight: FontWeight.w500,
  fontFamily: 'Poppins',
);

const InputDecoration kBaseDecoration = InputDecoration(
  border: InputBorder.none,
  isCollapsed: true,
  contentPadding: EdgeInsets.symmetric(vertical: 4),
);

String assetPathForOption(String option) {
  final fileKey = option.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return 'assets/icons/$fileKey.svg';
}

String buildPayNowPayloadJson({
  required String referenceId,
  required String paymentType,
  required String remarks,
  required String loanId,
  required String distributor,
  required String phoneNumber,
  required String formattedAmount,
}) {
  final isFailed = remarks.toLowerCase().contains('failed');
  final createdAt = DateTime.now().toUtc();
  final updatedAt = createdAt.add(const Duration(seconds: 2));
  final normalizedReference = referenceId.isEmpty ? loanId : referenceId;
  final amount = _parseAmount(formattedAmount);
  final token = createdAt.microsecondsSinceEpoch.toRadixString(16);

  final payload = <String, dynamic>{
    'id': 'py-$token',
    'business_id': '5f27a14a9bf05c73dd040bc8',
    'reference_id': normalizedReference,
    'payment_request_id': 'pr-$token',
    'payment_method': isFailed
        ? {
            'type': 'CARD',
            'card': {
              'channel_code': 'BANK_TRANSFER',
              'card_information': {
                'expiry_month': '12',
                'expiry_year': '28',
                'first_6_digits': '411111',
                'last_4_digits': '1111',
              },
            },
          }
        : {
            'type': 'EWALLET',
            'ewallet': {
              'channel_code': 'GCASH',
              'channel_properties': {
                'success_return_url': 'https://yourwebsite.com/success',
              },
            },
          },
    'amount': amount,
    'currency': 'IDR',
    'status': isFailed ? 'FAILED' : 'SUCCEEDED',
    'failure_code': isFailed ? 'CARD_DECLINED' : null,
    'created': createdAt.toIso8601String(),
    'updated': updatedAt.toIso8601String(),
    'metadata': {
      'customer_name': 'John Doe',
      'distributor': distributor,
      'cart_id': 'cart_$loanId',
      'phone_number': phoneNumber,
      'remarks': remarks,
    },
  };

  return jsonEncode(payload);
}

double _parseAmount(String formattedAmount) {
  final cleaned = formattedAmount.replaceAll(',', '');
  final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(cleaned);
  if (match == null) {
    return 0;
  }
  return double.tryParse(match.group(0) ?? '') ?? 0;
}

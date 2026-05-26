import 'package:flutter/material.dart';

class LoanPrincipalOption {
  const LoanPrincipalOption({
    required this.title,
    required this.logoAsset,
  });

  final String title;
  final String logoAsset;

  String get code => _principalCodeFromTitle(title);
}

class LoanOrderCard {
  LoanOrderCard({
    required this.title,
    required this.loanId,
    required this.logoAsset,
    required this.appliedAt,
    required this.dueAt,
    required this.originalAmount,
    required this.remainingAmount,
  });

  final String title;
  final String loanId;
  final String logoAsset;
  final DateTime appliedAt;
  final DateTime dueAt;
  final double originalAmount;
  double remainingAmount;

  String get appliedDateTime => formatLoanDate(appliedAt);
  String get dueDateTime => formatLoanDate(dueAt);
  String get amountDueText => formatAmount(remainingAmount);
}

String formatAmount(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0];
  final decimals = parts[1];

  final buffer = StringBuffer();
  for (int index = 0; index < whole.length; index++) {
    final reverseIndex = whole.length - index;
    buffer.write(whole[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }

  return '${buffer.toString()}.$decimals';
}

String formatLoanDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final year = (value.year % 100).toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$month-$day-$year  |  $hour:$minute';
}

String buildLoanId(int sequence, String principalCode) {
  final paddedSequence = sequence.toString().padLeft(3, '0');
  return 'AL-$paddedSequence$principalCode';
}

String _principalCodeFromTitle(String title) {
  final letters = title.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
  if (letters.isEmpty) {
    return 'XXX';
  }

  if (letters.length <= 3) {
    return letters.padRight(3, 'X');
  }

  return letters.substring(0, 3);
}

extension LoanOrderCardFormatting on LoanOrderCard {
  String get remainingPercentText {
    if (originalAmount <= 0) return '0%';
    final paidAmount = originalAmount - remainingAmount;
    final progress = (paidAmount / originalAmount).clamp(0.0, 1.0);
    return '${(progress * 100).toStringAsFixed(progress * 100 % 1 == 0 ? 0 : 1)}%';
  }

  double get remainingPercentValue {
    if (originalAmount <= 0) return 0;
    final paidAmount = originalAmount - remainingAmount;
    return (paidAmount / originalAmount).clamp(0.0, 1.0).toDouble();
  }
}
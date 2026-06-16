import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:p_sosyo/app/core/utils/principal_logo_resolver.dart';

class ScanSuccessReceiptModel {
  const ScanSuccessReceiptModel._({
    required this.qrData,
    required this.from,
    required this.to,
    required this.referenceId,
    required this.dateTime,
    required this.amountSent,
    required this.principalTitle,
    required this.principalLogo,
    required this.amountDueFromQr,
    required this.appliedDate,
    required this.dueDate,
    required this.products,
    required this.paymentReference,
  });

  factory ScanSuccessReceiptModel.fromQrData({
    required String qrData,
    String? from,
    String? to,
    String? referenceId,
    String? dateTime,
    double amountSent = 1834.08,
  }) {
    final Map<String, dynamic>? parsedQrJson = _parseQrJson(qrData);

    // Use only ReferenceID from QR payload
    final String resolvedReference = referenceId != null &&
            referenceId.trim().isNotEmpty
        ? referenceId.trim()
        : _stringValue(parsedQrJson?['ReferenceID']) ?? 'N/A';

    // Use current date/time if not provided
    final String resolvedDateTime =
        dateTime ?? DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    // Resolve sender and receiver
    final String resolvedFrom = from ?? 'MIKEL ROBBIE GARCIA ABOYME';
    final String resolvedTo =
        _stringValue(parsedQrJson?['principalTitle']) ?? to ?? '';

   final String resolvedPaymentReference =
    _stringValue(parsedQrJson?['payment_reference']) ??
        _stringValue(parsedQrJson?['paymentReference']) ??
        _stringValue(parsedQrJson?['payment_reference_id']) ??
        _stringValue(parsedQrJson?['paymentReferenceId']) ??
        _generatePaymentReference();

    return ScanSuccessReceiptModel._(
      qrData: qrData,
      from: resolvedFrom,
      to: resolvedTo,
      referenceId: resolvedReference,
      dateTime: resolvedDateTime,
      amountSent: amountSent,
      principalTitle:
          _stringValue(parsedQrJson?['principalTitle']) ?? to ?? '',
      principalLogo:
          principalLogoUrlForTitle(
                _stringValue(parsedQrJson?['principalTitle']) ?? to,
              ) ??
              _stringValue(parsedQrJson?['principalLogo']) ??
              '',
      amountDueFromQr:
          (parsedQrJson?['amountDue'] as num?)?.toDouble() ??
          (parsedQrJson?['amount_due'] as num?)?.toDouble() ??
          (parsedQrJson?['amount'] as num?)?.toDouble() ??
          (parsedQrJson?['totalAmount'] as num?)?.toDouble() ??
          (parsedQrJson?['total_amount'] as num?)?.toDouble() ??
          amountSent,
      appliedDate:
          _stringValue(parsedQrJson?['appliedDate']) ??
          _stringValue(parsedQrJson?['applied_date']) ??
          '',
      dueDate:
          _stringValue(parsedQrJson?['dueDate']) ??
          _stringValue(parsedQrJson?['due_date']) ??
          '',
      products: parsedQrJson?['products'] is List
          ? parsedQrJson!['products'] as List<dynamic>
          : const [],
      paymentReference: resolvedPaymentReference,
    );
  }

  final String qrData;
  final String? from;
  final String? to;
  final String? dateTime;
  final double amountSent;
  final String referenceId;
  final String principalTitle;
  final String principalLogo;
  final double amountDueFromQr;
  final String appliedDate;
  final String dueDate;
  final List<dynamic> products;
  final String paymentReference;

  /// Returns the parsed base QR JSON map for external enrichment.
  Map<String, dynamic> get parsedQrBase => _parseQrJson(qrData) ?? {};

  /// Builds an enriched QR JSON string using only ReferenceID.
  String get enrichedQrData {
    final Map<String, dynamic> base = parsedQrBase;

    // Ensure only one reference key exists
    base.remove('referenceId');
    base.remove('reference_id');
    base['ReferenceID'] = referenceId;

    base['from'] = from ?? 'UNKNOWN USER';
    base['to'] = to ?? principalTitle;
    base['date'] = dateTime ?? '';
    base['amountSent'] = amountSent;

    if (paymentReference != null && paymentReference!.isNotEmpty) {
      base['payment_reference'] = paymentReference;
    }

    return jsonEncode(base);
  }

  static Map<String, dynamic>? _parseQrJson(String qrData) {
    try {
      return jsonDecode(qrData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String? _stringValue(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
  
  static String _generatePaymentReference() {
  final now = DateTime.now();

  return '${now.year.toString().substring(2)}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';
}

}
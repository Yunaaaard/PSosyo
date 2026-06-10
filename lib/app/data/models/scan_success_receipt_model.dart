import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:p_sosyo/app/core/utils/principal_logo_resolver.dart';

class ScanSuccessReceiptModel {
  const ScanSuccessReceiptModel._({
    required this.qrData,
    required this.from,
    required this.to,
    required this.referenceNo,
    required this.dateTime,
    required this.amountSent,
    required this.loanId,
    required this.principalTitle,
    required this.principalLogo,
    required this.amountDueFromQr,
    required this.appliedDate,
    required this.dueDate,
    required this.products,
  });

  factory ScanSuccessReceiptModel.fromQrData({
    required String qrData,
    String? from,
    String? to,
    String? referenceNo,
    String? dateTime,
    double amountSent = 1834.08,
  }) {
    final Map<String, dynamic>? parsedQrJson = _parseQrJson(qrData);

    // Auto-generate 13-digit reference number if not provided
    final String resolvedRefNo = referenceNo ?? _generate13DigitRefNo();

    // Use current date/time if not provided
    final String resolvedDateTime = dateTime ??
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    // Resolve sender and receiver
    final String resolvedFrom = from ?? 'MIKEL ROBBIE GARCIA ABOYME';
    final String resolvedTo = _stringValue(parsedQrJson?['principalTitle']) ?? to ?? '';

    return ScanSuccessReceiptModel._(
      qrData: qrData,
      from: resolvedFrom,
      to: resolvedTo,
      referenceNo: resolvedRefNo,
      dateTime: resolvedDateTime,
      amountSent: amountSent,
      loanId: _stringValue(parsedQrJson?['loanId']) ?? 'N/A',
      principalTitle: _stringValue(parsedQrJson?['principalTitle']) ?? to ?? '',
        principalLogo:
          principalLogoUrlForTitle(_stringValue(parsedQrJson?['principalTitle']) ?? to) ??
            _stringValue(parsedQrJson?['principalLogo']) ??
            '',
      amountDueFromQr: (parsedQrJson?['amountDue'] as num?)?.toDouble() ?? amountSent,
      appliedDate: _stringValue(parsedQrJson?['appliedDate']) ?? '',
      dueDate: _stringValue(parsedQrJson?['dueDate']) ?? '',
      products: parsedQrJson?['products'] as List<dynamic>? ?? const [],
    );
  }

  final String qrData;
  final String? from;
  final String? to;
  final String? referenceNo;
  final String? dateTime;
  final double amountSent;
  final String loanId;
  final String principalTitle;
  final String principalLogo;
  final double amountDueFromQr;
  final String appliedDate;
  final String dueDate;
  final List<dynamic> products;

  /// Returns the parsed base QR JSON map for external enrichment.
  Map<String, dynamic> get parsedQrBase => _parseQrJson(qrData) ?? {};

  /// Builds an enriched QR JSON string that nests from/to/refNo/date/amountSent
  /// alongside the original loan payload data.
  String get enrichedQrData {
    final Map<String, dynamic> base = parsedQrBase;
    base['from'] = from ?? 'MIKEL ROBBIE GARCIA ABOYME';
    base['to'] = to ?? principalTitle;
    base['refNo'] = referenceNo ?? '';
    base['date'] = dateTime ?? '';
    base['amountSent'] = amountSent;
    return jsonEncode(base);
  }

  /// Generates a random 13-digit numeric reference number.
  static String _generate13DigitRefNo() {
    final random = Random();
    final buffer = StringBuffer();
    for (int i = 0; i < 13; i++) {
      buffer.write(random.nextInt(10));
    }
    return buffer.toString();
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
}
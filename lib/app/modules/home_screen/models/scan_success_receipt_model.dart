import 'dart:convert';

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

    return ScanSuccessReceiptModel._(
      qrData: qrData,
      from: from,
      to: to,
      referenceNo: referenceNo,
      dateTime: dateTime,
      amountSent: amountSent,
      loanId: _stringValue(parsedQrJson?['loanId']) ?? 'N/A',
      principalTitle: _stringValue(parsedQrJson?['principalTitle']) ?? to ?? '',
      principalLogo: _stringValue(parsedQrJson?['principalLogo']) ?? '',
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
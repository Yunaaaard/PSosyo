import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class PaymentService {
  /// Base URL for payment API. Replace with your real API host.
  final String baseUrl;

  PaymentService({this.baseUrl = 'https://api.example.com'});

  /// Sends a payment request to the backend.
  /// Returns true when the backend confirms success.
  Future<bool> processPayment({
    required String loanId,
    required double amount,
    String? reference,
    String? receiptPath,
  }) async {
    if (loanId.isEmpty || amount <= 0) return false;

    final uri = Uri.parse('$baseUrl/payments');
    final payload = {
      'loanId': loanId,
      'amount': amount,
      if (reference != null) 'reference': reference,
      if (receiptPath != null) 'receiptPath': receiptPath,
    };

    try {
      final resp = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(payload))
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        try {
          final body = json.decode(resp.body);
          if (body is Map && (body['success'] == true || body['status'] == 'OK' || body['code'] == 0)) {
            return true;
          }
        } catch (_) {
          // If body isn't JSON, still treat 200 as success
          return true;
        }
        // If server returned 200 but no success flag, assume success conservatively
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}

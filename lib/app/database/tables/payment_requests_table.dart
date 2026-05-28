import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class PaymentRequestsTable {
  PaymentRequestsTable(this._database);

  final Future<Database> Function() _database;

  static const String tableName = 'payment_requests';

  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE payment_requests (
        id TEXT PRIMARY KEY,
        loan_id TEXT,
        business_id TEXT,
        reference_id TEXT,
        payment_request_id TEXT,
        payment_method_json TEXT,
        amount REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT '',
        failure_code TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        metadata_json TEXT,
        FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> savePaymentRequest(
    Map<String, dynamic> payload, {
    String? loanId,
  }) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    final id = _stringValue(payload['id']) ??
        _stringValue(payload['payment_request_id']) ??
        now;

    await db.insert(
      tableName,
      <String, Object?>{
        'id': id,
        'loan_id': loanId,
        'business_id': _stringValue(payload['business_id']),
        'reference_id': _stringValue(payload['reference_id']),
        'payment_request_id': _stringValue(payload['payment_request_id']),
        'payment_method_json': payload['payment_method'] == null
            ? null
            : jsonEncode(payload['payment_method']),
        'amount': _doubleValue(payload['amount']) ?? 0,
        'currency': _stringValue(payload['currency']) ?? '',
        'status': _stringValue(payload['status']) ?? '',
        'failure_code': _stringValue(payload['failure_code']),
        'created_at': _stringValue(payload['created']) ?? now,
        'updated_at': _stringValue(payload['updated']) ?? now,
        'metadata_json': payload['metadata'] == null
            ? null
            : jsonEncode(payload['metadata']),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  String? _stringValue(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  double? _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString().replaceAll(',', '').trim());
  }
}

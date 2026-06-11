import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class PaymentRequestsTable {
  PaymentRequestsTable(this._database);

  final Future<Database> Function() _database;

  static const String tableName = 'payment_requests';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_requests (
        id TEXT PRIMARY KEY,
        loan_reference_id TEXT,
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
        FOREIGN KEY (loan_reference_id) REFERENCES loans(reference_id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> savePaymentRequest(
    Map<String, dynamic> payload, {
    String? loanReferenceId,
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
        'loan_reference_id': loanReferenceId,
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
        'metadata_json': jsonEncode({
          if (payload['metadata'] is Map) ...Map<String, dynamic>.from(payload['metadata'] as Map),
          if (payload['logo_asset'] != null) 'logo_asset': payload['logo_asset'],
        }),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> loadRecentPaymentRequests({int limit = 50}) async {
    final db = await _database();
    final rows = await db.query(
      tableName,
      orderBy: 'datetime(created_at) DESC, id DESC',
      limit: limit,
    );
    return rows;
  }

  Future<List<Map<String, Object?>>> loadAllPaymentRequests() async {
    final db = await _database();
    return db.query(
      tableName,
      orderBy: 'datetime(created_at) DESC, id DESC',
    );
  }

  Future<List<Map<String, Object?>>> loadPendingRequestsForLoan(String loanReferenceId) async {
    final db = await _database();
    return db.query(
      tableName,
      where: 'loan_reference_id = ? AND status = ?',
      whereArgs: [loanReferenceId, 'PENDING'],
    );
  }

  Future<int> markPendingRequestsAsSuccess(String loanReferenceId) async {
    final db = await _database();
    return db.update(
      tableName,
      <String, Object?>{
        'status': 'SUCCESS',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'loan_reference_id = ? AND status = ?',
      whereArgs: [loanReferenceId, 'PENDING'],
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

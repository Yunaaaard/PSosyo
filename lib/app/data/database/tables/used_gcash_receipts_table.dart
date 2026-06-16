import 'package:sqflite/sqflite.dart';

class UsedGcashReceiptsTable {
  UsedGcashReceiptsTable(this._database);

  final Future<Database> Function() _database;

  static const String tableName = 'used_gcash_receipts';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gcash_reference_id TEXT NOT NULL UNIQUE,
        loan_reference_id TEXT,
        amount REAL NOT NULL DEFAULT 0,
        used_at TEXT NOT NULL,
        FOREIGN KEY (loan_reference_id) REFERENCES loans(reference_id) ON DELETE SET NULL
      )
    ''');
  }

  /// Returns `true` when a receipt with [gcashReferenceId] has already been
  /// recorded as used.
  Future<bool> isReceiptUsed(String gcashReferenceId) async {
    final normalized = _normalize(gcashReferenceId);
    if (normalized.isEmpty) return false;

    final db = await _database();
    final rows = await db.query(
      tableName,
      columns: ['id'],
      where: 'gcash_reference_id = ?',
      whereArgs: [normalized],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Map<String, Object?>?> getReceiptUsage(String gcashReferenceId) async {
    final normalized = _normalize(gcashReferenceId);
    if (normalized.isEmpty) return null;

    final db = await _database();
    final rows = await db.query(
      tableName,
      where: 'gcash_reference_id = ?',
      whereArgs: [normalized],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Persists [gcashReferenceId] so it cannot be reused.
  Future<void> saveUsedReceipt({
    required String gcashReferenceId,
    String? loanReferenceId,
    double amount = 0,
  }) async {
    final normalized = _normalize(gcashReferenceId);
    if (normalized.isEmpty) return;

    final db = await _database();
    await db.insert(
      tableName,
      <String, Object?>{
        'gcash_reference_id': normalized,
        'loan_reference_id': loanReferenceId,
        'amount': amount,
        'used_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  String _normalize(String value) {
    return value.replaceAll(RegExp(r'[\s\-]'), '').trim();
  }
}

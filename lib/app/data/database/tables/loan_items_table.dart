import 'package:p_sosyo/app/data/models/loan_item_record.dart';
import 'package:sqflite/sqflite.dart';

class LoanItemsTable {
  LoanItemsTable(this._database);

  final Future<Database> Function() _database;

  static const String tableName = 'loan_items';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS loan_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        sku TEXT NOT NULL DEFAULT '',
        quantity INTEGER NOT NULL DEFAULT 0,
        unit_price REAL NOT NULL DEFAULT 0,
        total_price REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (reference_id) REFERENCES loans(reference_id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> replaceLoanItems(
    String referenceId,
    List<LoanItemRecord> items,
  ) async {
    final db = await _database();
    await replaceLoanItemsInTransaction(db, referenceId, items);
  }

  Future<void> replaceLoanItemsInTransaction(
    DatabaseExecutor executor,
    String referenceId,
    List<LoanItemRecord> items,
  ) async {
    final now = DateTime.now().toIso8601String();
    await executor.delete(
      tableName,
      where: 'reference_id = ?',
      whereArgs: <Object?>[referenceId],
    );
    for (final item in items) {
      await executor.insert(
        tableName,
        <String, Object?>{
          'reference_id': referenceId,
          'product_name': item.productName,
          'sku': item.sku,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
          'created_at': now,
        },
      );
    }
  }

  Future<List<LoanItemRecord>> loadLoanItemsForReference(
    String referenceId,
  ) async {
    final db = await _database();
    final rows = await db.query(
      tableName,
      where: 'reference_id = ?',
      whereArgs: <Object?>[referenceId],
      orderBy: 'id ASC',
    );

    return rows.map((row) {
      return LoanItemRecord(
        productName: row['product_name']?.toString() ?? '',
        sku: row['sku']?.toString() ?? '',
        quantity: _intValue(row['quantity']),
        unitPrice: _doubleValue(row['unit_price']),
        totalPrice: _doubleValue(row['total_price']),
      );
    }).toList();
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

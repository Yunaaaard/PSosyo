import 'package:sqflite/sqflite.dart';

class LoanItemRecord {
  const LoanItemRecord({
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
}

class LoanItemsTable {
  LoanItemsTable(this._database);

  final Future<Database> Function() _database;

  static const String tableName = 'loan_items';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS loan_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        sku TEXT NOT NULL DEFAULT '',
        quantity INTEGER NOT NULL DEFAULT 0,
        unit_price REAL NOT NULL DEFAULT 0,
        total_price REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> replaceLoanItems(
    String loanId,
    List<LoanItemRecord> items,
  ) async {
    final db = await _database();
    await replaceLoanItemsInTransaction(db, loanId, items);
  }

  Future<void> replaceLoanItemsInTransaction(
    DatabaseExecutor executor,
    String loanId,
    List<LoanItemRecord> items,
  ) async {
    final now = DateTime.now().toIso8601String();
    await executor.delete(
      tableName,
      where: 'loan_id = ?',
      whereArgs: <Object?>[loanId],
    );
    for (final item in items) {
      await executor.insert(
        tableName,
        <String, Object?>{
          'loan_id': loanId,
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
}

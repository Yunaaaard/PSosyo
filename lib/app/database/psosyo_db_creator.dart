import 'package:p_sosyo/app/database/tables/loan_items_table.dart';
import 'package:p_sosyo/app/database/tables/loans_table.dart';
import 'package:p_sosyo/app/database/tables/payment_requests_table.dart';
import 'package:p_sosyo/app/database/tables/users_table.dart';
import 'package:sqflite/sqflite.dart';

class PsosyoDbCreator {
  const PsosyoDbCreator._();

  static Future<void> create(Database db, int version) async {
    await UsersTable.create(db);
    await LoansTable.create(db);
    await LoanItemsTable.create(db);
    await PaymentRequestsTable.create(db);

    await db.execute(
      'CREATE INDEX idx_loans_principal_status ON loans(principal_title, status)',
    );
    await db.execute('CREATE INDEX idx_loans_loan_id ON loans(loan_id)');
    await db
        .execute('CREATE INDEX idx_loan_items_loan_id ON loan_items(loan_id)');
  }

  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 3 && newVersion >= 3) {
      await _upgradeTo3(db);
    }
    if (oldVersion < 4 && newVersion >= 4) {
      await _upgradeTo4(db);
    }
  }

  static Future<void> _upgradeTo3(Database db) async {
    // Add separated address fields to users table
    await db.execute("ALTER TABLE users ADD COLUMN street TEXT NOT NULL DEFAULT ''");
    await db.execute("ALTER TABLE users ADD COLUMN postal_code TEXT NOT NULL DEFAULT ''");
    await db.execute("ALTER TABLE users ADD COLUMN city TEXT NOT NULL DEFAULT ''");
    await db.execute("ALTER TABLE users ADD COLUMN country TEXT NOT NULL DEFAULT ''");
  }

  static Future<void> _upgradeTo4(Database db) async {
    // Remove principal_logo column from loans table by recreating the table.
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.execute('BEGIN TRANSACTION');

    // Create new table without principal_logo
    await db.execute('''
      CREATE TABLE loans_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_id TEXT NOT NULL UNIQUE,
        user_id INTEGER,
        principal_title TEXT NOT NULL,
        amount_due REAL NOT NULL,
        remaining_amount REAL NOT NULL,
        applied_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ACTIVE',
        raw_payload TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');

    // Copy data from old loans table into new table (omit principal_logo)
    await db.execute('''
      INSERT INTO loans_new (loan_id, user_id, principal_title, amount_due, remaining_amount, applied_date, due_date, status, raw_payload, created_at, updated_at)
      SELECT loan_id, user_id, principal_title, amount_due, remaining_amount, applied_date, due_date, status, raw_payload, created_at, updated_at FROM loans;
    ''');

    // Drop old table and rename new table
    await db.execute('DROP TABLE loans');
    await db.execute('ALTER TABLE loans_new RENAME TO loans');

    // Recreate indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_loans_principal_status ON loans(principal_title, status)',
    );
    await db.execute('CREATE INDEX IF NOT EXISTS idx_loans_loan_id ON loans(loan_id)');

    await db.execute('COMMIT');
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // static Future<void> upgrade(
  //   Database db,
  //   int oldVersion,
  //   int newVersion,
  // ) async {
  //   if (oldVersion < 3 && newVersion >= 3) {
  //     await _upgradeTo3(db);
  //   }
  // }
}
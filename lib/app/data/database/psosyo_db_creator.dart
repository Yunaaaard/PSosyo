import 'package:p_sosyo/app/data/database/tables/loan_items_table.dart';
import 'package:p_sosyo/app/data/database/tables/loans_table.dart';
import 'package:p_sosyo/app/data/database/tables/payment_requests_table.dart';
import 'package:p_sosyo/app/data/database/tables/users_table.dart';
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
    await db.execute('CREATE INDEX idx_loans_reference_id ON loans(reference_id)');
    await db
        .execute('CREATE INDEX idx_loan_items_reference_id ON loan_items(reference_id)');
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
    if (oldVersion < 5 && newVersion >= 5) {
      await _upgradeTo5(db);
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
        reference_id TEXT NOT NULL UNIQUE,
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
      INSERT INTO loans_new (reference_id, user_id, principal_title, amount_due, remaining_amount, applied_date, due_date, status, raw_payload, created_at, updated_at)
      SELECT loan_id, user_id, principal_title, amount_due, remaining_amount, applied_date, due_date, status, raw_payload, created_at, updated_at FROM loans;
    ''');

    // Drop old table and rename new table
    await db.execute('DROP TABLE loans');
    await db.execute('ALTER TABLE loans_new RENAME TO loans');

    // Recreate indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_loans_principal_status ON loans(principal_title, status)',
    );
    await db.execute('CREATE INDEX IF NOT EXISTS idx_loans_reference_id ON loans(reference_id)');

    await db.execute('COMMIT');
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _upgradeTo5(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.execute('BEGIN TRANSACTION');

    await db.execute('''
      CREATE TABLE loans_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference_id TEXT NOT NULL UNIQUE,
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

    await db.execute('''
      INSERT INTO loans_new (
        reference_id, user_id, principal_title, amount_due, remaining_amount,
        applied_date, due_date, status, raw_payload, created_at, updated_at
      )
      SELECT
        loan_id, user_id, principal_title, amount_due, remaining_amount,
        applied_date, due_date, status, raw_payload, created_at, updated_at
      FROM loans;
    ''');

    await db.execute('DROP TABLE loans');
    await db.execute('ALTER TABLE loans_new RENAME TO loans');

    await db.execute('''
      CREATE TABLE loan_items_new (
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

    await db.execute('''
      INSERT INTO loan_items_new (
        reference_id, product_name, sku, quantity, unit_price, total_price, created_at
      )
      SELECT
        loan_id, product_name, sku, quantity, unit_price, total_price, created_at
      FROM loan_items;
    ''');

    await db.execute('DROP TABLE loan_items');
    await db.execute('ALTER TABLE loan_items_new RENAME TO loan_items');

    await db.execute('''
      CREATE TABLE payment_requests_new (
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

    await db.execute('''
      INSERT INTO payment_requests_new (
        id, loan_reference_id, business_id, reference_id, payment_request_id,
        payment_method_json, amount, currency, status, failure_code,
        created_at, updated_at, metadata_json
      )
      SELECT
        id, loan_id, business_id, reference_id, payment_request_id,
        payment_method_json, amount, currency, status, failure_code,
        created_at, updated_at, metadata_json
      FROM payment_requests;
    ''');

    await db.execute('DROP TABLE payment_requests');
    await db.execute('ALTER TABLE payment_requests_new RENAME TO payment_requests');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_loans_principal_status ON loans(principal_title, status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_loans_reference_id ON loans(reference_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_loan_items_reference_id ON loan_items(reference_id)',
    );

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

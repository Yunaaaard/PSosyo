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
  }

  static Future<void> _upgradeTo3(Database db) async {
    // Add separated address fields to users table
    await db.execute("ALTER TABLE users ADD COLUMN street TEXT NOT NULL DEFAULT ''");
    await db.execute("ALTER TABLE users ADD COLUMN postal_code TEXT NOT NULL DEFAULT ''");
    await db.execute("ALTER TABLE users ADD COLUMN city TEXT NOT NULL DEFAULT ''");
    await db.execute("ALTER TABLE users ADD COLUMN country TEXT NOT NULL DEFAULT ''");
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

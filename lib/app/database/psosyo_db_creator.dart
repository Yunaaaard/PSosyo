import 'package:p_sosyo/app/database/tables/loan_items_table.dart';
import 'package:p_sosyo/app/database/tables/loans_table.dart';
import 'package:p_sosyo/app/database/tables/payment_requests_table.dart';
import 'package:p_sosyo/app/database/tables/users_table.dart';
import 'package:sqflite/sqflite.dart';

class PsosyoDbCreator {
  const PsosyoDbCreator._();

  static Future<void> create(Database db, int version) async {
    await db.transaction((txn) async {
      await _createSchema(txn);
    });
  }

  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await db.transaction((txn) async {
      if (oldVersion < 3) {
        await _createSchema(txn);
      }
    });
  }

  static Future<void> _createSchema(DatabaseExecutor executor) async {
    await UsersTable.create(executor);
    await LoansTable.create(executor);
    await LoanItemsTable.create(executor);
    await PaymentRequestsTable.create(executor);

    await executor.execute(
      'CREATE INDEX IF NOT EXISTS idx_loans_principal_status ON loans(principal_title, status)',
    );
    await executor.execute('CREATE INDEX IF NOT EXISTS idx_loans_loan_id ON loans(loan_id)');
    await executor.execute('CREATE INDEX IF NOT EXISTS idx_loan_items_loan_id ON loan_items(loan_id)');
  }
}

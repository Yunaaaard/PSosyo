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
  ) async {}
}

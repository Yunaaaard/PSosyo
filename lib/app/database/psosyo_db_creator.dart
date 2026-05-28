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

import 'package:sqflite/sqflite.dart';

class UsersTable {
  UsersTable(this._database);

  final Future<Database> Function() _database;

  static const String tableName = 'users';

  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT UNIQUE,
        full_name TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL DEFAULT '',
        date_of_birth TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT '',
        gender TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<int?> resolveUserId({String? phoneNumber}) async {
    final normalizedPhone = phoneNumber?.trim();
    if (normalizedPhone == null || normalizedPhone.isEmpty) {
      return null;
    }

    final db = await _database();
    final existingRows = await db.query(
      tableName,
      columns: <String>['id'],
      where: 'phone_number = ?',
      whereArgs: <Object?>[normalizedPhone],
      limit: 1,
    );
    if (existingRows.isNotEmpty) {
      return existingRows.first['id'] as int?;
    }

    final now = DateTime.now().toIso8601String();
    return await db.insert(
      tableName,
      <String, Object?>{
        'phone_number': normalizedPhone,
        'full_name': '',
        'email': '',
        'date_of_birth': '',
        'status': '',
        'gender': '',
        'address': '',
        'created_at': now,
        'updated_at': now,
      },
    );
  }

  Future<void> saveUserProfile({
    String? phoneNumber,
    required String fullName,
    required String email,
    required String dateOfBirth,
    required String status,
    required String gender,
    required String address,
  }) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    final normalizedPhone = phoneNumber?.trim();
    final existingId = await resolveUserId(phoneNumber: normalizedPhone);

    final values = <String, Object?>{
      'phone_number': normalizedPhone,
      'full_name': fullName,
      'email': email,
      'date_of_birth': dateOfBirth,
      'status': status,
      'gender': gender,
      'address': address,
      'updated_at': now,
    };

    if (existingId == null) {
      values['created_at'] = now;
      await db.insert(tableName, values);
      return;
    }

    await db.update(
      tableName,
      values,
      where: 'id = ?',
      whereArgs: <Object?>[existingId],
    );
  }

  Future<void> saveRegisteredPhone(String phoneNumber) async {
    await saveUserProfile(
      phoneNumber: phoneNumber,
      fullName: '',
      email: '',
      dateOfBirth: '',
      status: '',
      gender: '',
      address: '',
    );
  }
}

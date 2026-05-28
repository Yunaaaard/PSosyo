import 'package:sqflite/sqflite.dart';

class UsersTable {
  UsersTable(this._database);

  final Future<Database> Function() _database;

  static const String tableName = 'users';

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT UNIQUE,
        full_name TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL DEFAULT '',
        date_of_birth TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT '',
        gender TEXT NOT NULL DEFAULT '',
        street TEXT NOT NULL DEFAULT '',
        postal_code TEXT NOT NULL DEFAULT '',
        city TEXT NOT NULL DEFAULT '',
        country TEXT NOT NULL DEFAULT '',
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
        'street': '',
        'postal_code': '',
        'city': '',
        'country': '',
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
    required String street,
    required String postalCode,
    required String city,
    required String country,
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
      'street': street,
      'postal_code': postalCode,
      'city': city,
      'country': country,
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
      street: '',
      postalCode: '',
      city: '',
      country: '',
    );
  }

  Future<String?> getFullNameByPhone(String? phoneNumber) async {
    final normalizedPhone = phoneNumber?.trim();
    if (normalizedPhone == null || normalizedPhone.isEmpty) {
      return null;
    }

    final db = await _database();
    final rows = await db.query(
      tableName,
      columns: <String>['full_name'],
      where: 'phone_number = ?',
      whereArgs: <Object?>[normalizedPhone],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final fullName = rows.first['full_name']?.toString().trim() ?? '';
    return fullName.isEmpty ? null : fullName;
  }

  Future<String?> getLatestFullName() async {
    final db = await _database();
    final rows = await db.query(
      tableName,
      columns: <String>['full_name'],
      where: 'full_name <> ?',
      whereArgs: <Object?>[''],
      orderBy: 'updated_at DESC, created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final fullName = rows.first['full_name']?.toString().trim() ?? '';
    return fullName.isEmpty ? null : fullName;
  }

  Future<String?> getLatestPhoneNumber() async {
    final db = await _database();
    final rows = await db.query(
      tableName,
      columns: <String>['phone_number'],
      where: 'phone_number <> ?',
      whereArgs: <Object?>[''],
      orderBy: 'updated_at DESC, created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final phoneNumber = rows.first['phone_number']?.toString().trim() ?? '';
    return phoneNumber.isEmpty ? null : phoneNumber;
  }
}

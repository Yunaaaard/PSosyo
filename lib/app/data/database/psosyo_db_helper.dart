import 'package:path/path.dart' as p;
import 'package:p_sosyo/app/data/database/psosyo_db_creator.dart';
import 'package:sqflite/sqflite.dart';

class PsosyoDbHelper {
  static const String databaseName = 'psosyo.db';
  static const int databaseVersion = 5;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final basePath = await getDatabasesPath();
    final databasePath = p.join(basePath, databaseName);

    return openDatabase(
      databasePath,
      version: databaseVersion,
      onCreate: PsosyoDbCreator.create,
      onUpgrade: PsosyoDbCreator.upgrade,
    );
  }
}

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  late Future<Database> _database;

  SqliteService() {
    _database = _init();
  }

  Future<Database> get database => _database;

  Future<Database> _init() async {
    return openDatabase(
      join(await getDatabasesPath(), 'projectmap.db'),
      onCreate: (db, version) async {
        await db.execute('''
              CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                googleId TEXT NOT NULL UNIQUE,
                email TEXT NOT NULL UNIQUE,
                avatarUrl TEXT,
                isLocationSharing INTEGER NOT NULL DEFAULT 1
              )
            ''');
      },
      version: 1,
    );
  }
}

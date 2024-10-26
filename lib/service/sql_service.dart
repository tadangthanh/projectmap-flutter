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
                isLocationSharing INTEGER NOT NULL DEFAULT 1,
                idToken TEXT NOT NULL,
                batteryLevel INTEGER NOT NULL DEFAULT 100,
                latitude REAL NOT NULL DEFAULT 0.0,
                longitude REAL NOT NULL DEFAULT 0.0
              )
            ''');
        await db.execute(''' 
              CREATE TABLE IF NOT EXISTS locations_search_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                description TEXT NOT NULL,
                placeId TEXT NOT NULL,
                mainText TEXT NOT NULL,
                secondaryText TEXT NULL,
                createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now')) -- Thời gian tạo dưới dạng dấu thời gian Unix
              )
            ''');
        await db.execute('''
            CREATE TABLE IF NOT EXISTS tokens (
              id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID tự động tăng
              accessToken TEXT NOT NULL,            -- Lưu access token
              refreshToken TEXT NOT NULL           -- Lưu refresh token
            )
          ''');
      },
      version: 1,
    );
  }
}

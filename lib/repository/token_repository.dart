import 'package:map/main.dart';
import 'package:map/service/sql_service.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/token.dart';

class TokenRepo{
  final SqliteService _sqliteService = getIt<SqliteService>();

  Future<Token> saveToken(Token token) async {
    final db = await _sqliteService.database;
    await db.insert('tokens', token.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return token;
  }

  Future<void> deleteToken() async{
    final db = await _sqliteService.database;
    await db.delete('tokens');
  }
  Future<Token> updateToken(Token token )async{
    final db = await _sqliteService.database;
    await db.update('tokens', token.toMap(), where: 'id = ?', whereArgs: [token.id]);
    return token;
  }
}
import 'package:map/entity/token_response.dart';
import 'package:map/main.dart';
import 'package:map/service/sql_service.dart';
import 'package:sqflite/sqflite.dart';

class TokenRepo{
  final SqliteService _sqliteService = getIt<SqliteService>();


  Future<TokenResponse> saveToken(TokenResponse token) async {
    final db = await _sqliteService.database;
    await db.insert('tokens', token.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return token;
  }

  Future<void> deleteToken() async{
    final db = await _sqliteService.database;
    await db.delete('tokens');
  }
  Future<TokenResponse> updateToken(TokenResponse token )async{
    final db = await _sqliteService.database;
    await db.update('tokens', token.toMap(), where: 'id = ?', whereArgs: [token.id]);
    return token;
  }
  Future<TokenResponse?> getToken() async {
    final db = await _sqliteService.database;
    List<Map<String, dynamic>> maps = await db.query('tokens');
    if(maps.isNotEmpty){
      return TokenResponse.fromMap(maps.first);
    }
    return null;
  }
}
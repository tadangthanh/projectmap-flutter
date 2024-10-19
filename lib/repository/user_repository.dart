import 'dart:ffi';

import 'package:map/entity/user.dart';
import 'package:map/service/sql_service.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';

class UserRepository {
  final SqliteService sqliteService = getIt<SqliteService>();

  Future<User> saveUser(User user) async {
    final db = await sqliteService.database;
    user.id = await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return user;
  }

  Future<User?> getUser() async {
    final db = await sqliteService.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  Future<void> deleteUser()async {
    final db = await sqliteService.database;
    await db.delete('users');
  }
}

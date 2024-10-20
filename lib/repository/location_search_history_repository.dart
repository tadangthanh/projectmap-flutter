import 'package:map/entity/place_prediction.dart';
import 'package:map/main.dart';
import 'package:map/service/sql_service.dart';
import 'package:sqflite/sqflite.dart';

class LocationSearchHistoryRepo {
  final SqliteService sqliteService = getIt<SqliteService>();

  Future<List<PlacePrediction>> getSearchHistory() async {
    final Database db = await sqliteService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'locations_search_history',
      orderBy: 'createdAt DESC', // Sắp xếp theo createdAt từ mới đến cũ
    );

    return List.generate(maps.length, (i) {
      return PlacePrediction.fromMap(maps[i]);
    });
  }

  Future<PlacePrediction> saveLocationSearch(
      PlacePrediction placePrediction) async {
    final Database db = await sqliteService.database;
    placePrediction.id = await db.insert(
        'locations_search_history', placePrediction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return placePrediction;
  }
  Future<bool> isExistByPlaceName(String placeName) async {
    final Database db = await sqliteService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'locations_search_history',
      where: 'mainText COLLATE NOCASE = ?',
      whereArgs: [placeName],
    );
    return maps.isNotEmpty;
  }

  Future<PlacePrediction?> findByMainText(String mainText) async {
    final Database db = await sqliteService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'locations_search_history',
      where: 'mainText COLLATE NOCASE = ?',
      whereArgs: [mainText],
    );
    if (maps.isNotEmpty) {
      return PlacePrediction.fromMap(maps.first);
    }
    return null;
  }


  Future<void> deleteLocationSearch(int id) async {
    final Database db = await sqliteService.database;
    await db.delete(
      'locations_search_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<PlacePrediction> updateById(int id,PlacePrediction placePrediction) async {
    final Database db = await sqliteService.database;
    await db.update(
      'locations_search_history',
      placePrediction.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    return placePrediction;
  }
}

import 'package:map/main.dart';

import '../entity/place_prediction.dart';
import '../repository/location_search_history_repository.dart';

class LocationSearchHistoryService{
  final LocationSearchHistoryRepo locationSearchHistoryRepo =getIt<LocationSearchHistoryRepo>();

  Future<List<PlacePrediction>> getSearchHistory() async {
    return await locationSearchHistoryRepo.getSearchHistory();
  }
  Future<void> deleteLocationSearch(int id) async {
    await locationSearchHistoryRepo.deleteLocationSearch(id);
  }
  Future<PlacePrediction> saveLocationSearch(
      PlacePrediction placePrediction) async {
    PlacePrediction? placePredictionExist = await locationSearchHistoryRepo.findByMainText(placePrediction.mainText);
    if (placePredictionExist != null) {
      placePrediction.id = placePredictionExist.id;
      placePrediction.createdAt = DateTime.now();
      return await locationSearchHistoryRepo.updateById(placePredictionExist.id!, placePrediction);
    }
    return await locationSearchHistoryRepo.saveLocationSearch(placePrediction);
  }
}
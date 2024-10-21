import 'package:map/entity/place_prediction.dart';

class SearchEvent {}
class InitSearchEvent extends SearchEvent {}
class SearchQueryEvent extends SearchEvent {
  final String query;
  SearchQueryEvent({required this.query});
}
class ExecuteSearchEvent extends SearchEvent {
  final PlacePrediction placePrediction;
  ExecuteSearchEvent({required this.placePrediction});
}
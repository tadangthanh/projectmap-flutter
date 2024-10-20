import 'package:map/entity/place_prediction.dart';

class SearchState{}
class SearchSuggestionsState extends SearchState{
  final List<PlacePrediction> suggestions;
  final String query;
  SearchSuggestionsState({required this.suggestions ,required this.query});
}
class SearchPendingState extends SearchState{
  final List<PlacePrediction> history;
  SearchPendingState({required this.history});
}
class SearchFailure extends SearchState {
  final String message;

  SearchFailure(this.message);
}
class SearchLoading extends SearchState{}
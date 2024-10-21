import 'package:map/entity/place.dart';
import 'package:map/entity/place_prediction.dart';

class SearchState{}
class SearchSuggestionsState extends SearchState{
  final List<PlacePrediction> suggestions;
  final String query;
  SearchSuggestionsState({required this.suggestions ,required this.query});
}

class SearchFailure extends SearchState {
  final String message;

  SearchFailure(this.message);
}
class SearchLoading extends SearchState{}
class FinishSearchState extends SearchState{
  final Place place;
  FinishSearchState(this.place);
}
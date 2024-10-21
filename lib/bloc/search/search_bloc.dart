import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map/bloc/map/map_bloc.dart';
import 'package:map/bloc/map/map_event.dart';
import 'package:map/bloc/map/map_state.dart';
import 'package:map/bloc/search/search_event.dart';
import 'package:map/bloc/search/search_state.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/place_prediction.dart';
import 'package:map/main.dart';
import 'package:map/service/location_search_history_service.dart';
import 'package:map/service/place_search.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final PlaceSearch _placeSearch = getIt<PlaceSearch>();
  final List<PlacePrediction> _history = [];
  final LocationSearchHistoryService _locationSearchHistoryService =
      getIt<LocationSearchHistoryService>();

  SearchBloc() : super(SearchSuggestionsState(suggestions: [], query: '')) {
    on<SearchQueryEvent>((event, emit) async {
      await _query(emit, event.query);
    });
    on<ExecuteSearchEvent>((event, emit) async {
      await _executeSearch(emit, event.placePrediction);
    });
    on<InitSearchEvent>((event, emit) async {
      await _init(emit);
    });
    add(InitSearchEvent());
  }

  Future<void> _init(Emitter<SearchState> emit) async {
    final history = await _locationSearchHistoryService.getSearchHistory();
    _history.clear();
    _history.addAll(history);
    emit(SearchSuggestionsState(suggestions: _history, query: ''));
  }

  // lấy goi y từ google map
  Future<void> _query(Emitter<SearchState> emit, String query) async {
    final predictions = await _placeSearch.getAutocomplete(query);
    if (query.trim().isEmpty) {
      emit(SearchSuggestionsState(suggestions: _history, query: query));
      return;
    }
    emit(SearchSuggestionsState(suggestions: predictions, query: query));
  }

// lưu lịch sử tìm kiếm
  Future<void> _executeSearch(
      Emitter<SearchState> emit, PlacePrediction placePrediction) async {
    emit(SearchLoading()); // Phát trạng thái đang tìm kiếm
    Place place =
        await _placeSearch.searchPlaceDetailById(placePrediction.placeId);
    emit(FinishSearchState(place)); // Phát trạng thái tìm kiếm thành công
    // return;
    // try {
    //   List<Location> locations =
    //       await locationFromAddress(placePrediction.mainText);
    //
    //   // Kiểm tra nếu danh sách locations không rỗng
    //   if (locations.isNotEmpty) {
    //     double latitude = locations.first.latitude;
    //     double longitude = locations.first.longitude;
    //
    //     print('Tọa độ: ($latitude, $longitude)');
    //     await _locationSearchHistoryService.saveLocationSearch(placePrediction);
    //   } else {
    //     print('Không tìm thấy vị trí cho địa chỉ: ${placePrediction.mainText}');
    //   }
    // } catch (e) {
    //   emit(SearchFailure(
    //       'Không tìm thấy địa chỉ')); // Phát trạng thái thất bại với thông báo lỗi
    //   print('Lỗi: $e'); // In ra lỗi nếu có
    // }
  }
}

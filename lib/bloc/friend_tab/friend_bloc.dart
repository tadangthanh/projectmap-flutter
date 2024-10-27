import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/friend_tab/friend_event.dart';
import 'package:map/bloc/friend_tab/friend_state.dart';

import '../../dto/user_search_response.dart';
import '../../dto/user_search_response_page.dart';
import '../../main.dart';
import '../../service/user_service.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final UserService _userService = getIt<UserService>();
  late UserSearchResponsePage _pageUser;
  late List<UserSearchResponse> _listUser;
  late bool _hasNext= false;

  FriendBloc() : super(FriendState()) {
    on<InitialFriendEvent>((event, emit) async {
      await _init(emit);
    });
    on<LoadMoreFriendEvent>((event, emit) async {
      await _loadMore(emit);
    });


    add(InitialFriendEvent());
  }
  Future<void> _loadMore(Emitter<FriendState> emit) async {
    emit(FriendLoaded(listUser: _listUser, isLoading: true, hasNext: _hasNext));
    try {
      if(!_hasNext){
        emit(FriendLoaded(listUser: _listUser, isLoading: false, hasNext: false));
        return;
      }
      _pageUser = await _userService.getFriendPendingAccept(page: _pageUser.pageNo+1);
      _hasNext = _pageUser.hasNext;
      _listUser.addAll(_pageUser.items);
      emit(FriendLoaded(listUser: _listUser, isLoading: false, hasNext: _hasNext));
    } catch (e) {
      emit(FriendError(message: e.toString()));
    }
  }

  Future<void> _init(Emitter<FriendState> emit) async {
    emit(LoadingFriendState());
    try {
      _clearData();
      _pageUser = await _userService.getFriends();
      _hasNext = _pageUser.hasNext;
      _listUser = _pageUser.items;
      emit(FriendLoaded(listUser:_listUser, isLoading: false, hasNext: _hasNext));
    } catch (e) {
      emit(FriendError(message: e.toString()));
    }
  }

  void _clearData() {
    _listUser = [];
    _hasNext = false;
  }
}

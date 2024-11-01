import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/friend_request_tab/friend_request_event.dart';
import 'package:map/bloc/friend_request_tab/friend_request_state.dart';
import 'package:map/dto/page_response.dart';
import 'package:map/main.dart';
import 'package:map/service/user_service.dart';

import '../../dto/user_search_response.dart';
import '../../dto/user_search_response_page.dart';

class FriendRequestBloc extends Bloc<FriendRequestEvent, FriendRequestState> {
  final UserService _userService = getIt<UserService>();
  late PageResponse<UserSearchResponse> _pageUser;
  late List<UserSearchResponse> _listUser;
  late bool _hasNext= false;

  FriendRequestBloc() : super(FriendRequestState()) {
    on<InitFriendRequestEvent>((event, emit) async {
      await _init(emit);
    });
    on<AcceptFriendEvent>((event, emit) async {
      await _acceptFriend(event.email, emit);
    });
    on<RejectFriendRequestEvent>((event, emit) async {
      await _rejectFriendRequest(event.email, emit);
    });
    on<LoadMoreFriendRequestEvent>((event, emit) async {
      await _loadMore(emit);
    });
    add(InitFriendRequestEvent());
  }
  Future<void> _acceptFriend(String email, Emitter<FriendRequestState> emit) async {
    try {
      await _userService.acceptFriend(email);
      _listUser.removeWhere((element) => element.email == email);
      emit(FriendRequestLoaded(listUser: _listUser, isLoading: false, hasNext: _hasNext));
    } catch (e) {
      emit(FriendRequestError(message: e.toString()));
    }
  }
  Future<void> _rejectFriendRequest(String email, Emitter<FriendRequestState> emit) async {
    try {
      await _userService.rejectRequestAddFriend(email);
      _listUser.removeWhere((element) => element.email == email);
      emit(FriendRequestLoaded(listUser: _listUser, isLoading: false, hasNext: _hasNext));
    } catch (e) {
      emit(FriendRequestError(message: e.toString()));
    }
  }

  Future<void> _loadMore(Emitter<FriendRequestState> emit) async {
    emit(FriendRequestLoaded(listUser: _listUser, isLoading: true, hasNext: _hasNext));
    try {
      if(!_hasNext){
        emit(FriendRequestLoaded(listUser: _listUser, isLoading: false, hasNext: false));
        return;
      }
      _pageUser = await _userService.getFriendPendingAccept(page: _pageUser.pageNo+1);
      _hasNext = _pageUser.hasNext;
      _listUser.addAll(_pageUser.items);
      emit(FriendRequestLoaded(listUser: _listUser, isLoading: false, hasNext: _hasNext));
    } catch (e) {
      emit(FriendRequestError(message: e.toString()));
    }
  }
  Future<void> _init(Emitter<FriendRequestState> emit) async {
    emit(FriendRequestLoading());
    try {
      _clearData();
      _pageUser = await _userService.getFriendPendingAccept();
      _hasNext = _pageUser.hasNext;
      _listUser = _pageUser.items;
      emit(FriendRequestLoaded(listUser:_listUser, isLoading: false, hasNext: _hasNext));
    } catch (e) {
      emit(FriendRequestError(message: e.toString()));
    }
  }

  void _clearData() {
    _listUser = [];
    _hasNext = false;
  }
}

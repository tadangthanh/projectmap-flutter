import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/friend_tab/friend_event.dart';
import 'package:map/bloc/friend_tab/friend_state.dart';
import 'package:map/dto/page_response.dart';

import '../../dto/user_search_response.dart';
import '../../main.dart';
import '../../service/user_service.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final UserService _userService = getIt<UserService>();
  late PageResponse<UserSearchResponse> _pageUser;
  late List<UserSearchResponse> _listUser;
  late bool _hasNext = false;
  late bool _isLoading = false;
  late List<int> _friendsSelectedId;

  FriendBloc() : super(FriendState()) {
    on<InitialFriendEvent>((event, emit) async {
      await _init(emit);
    });
    on<LoadMoreFriendEvent>((event, emit) async {
      await _loadMore(emit);
    });
    on<UnFriendEvent>((event, emit) async {
      await _unFriend(event, emit);
    });
    on<SelectFriendEvent>((event, emit) async {
      await _selectFriend(event.id, emit);
    });
    add(InitialFriendEvent());
  }

  Future<void> _selectFriend(int id, Emitter<FriendState> emit) async {
    try {
      if (_friendsSelectedId.contains(id)) {
        _friendsSelectedId.remove(id);
      } else {
        _friendsSelectedId.add(id);
      }
      _emitFriendLoaded(emit);
    } catch (e) {
      emit(FriendError(message: e.toString()));
    }
  }

  void _emitFriendLoaded(Emitter<FriendState> emit) {
    emit(FriendLoaded(
        listUser: _listUser,
        isLoading: _isLoading,
        hasNext: _hasNext,
        friendsSelectedId: _friendsSelectedId));
  }

  Future<void> _unFriend(UnFriendEvent event, Emitter<FriendState> emit) async {
    emit(FriendLoaded(listUser: _listUser, isLoading: true, hasNext: _hasNext));
    try {
      await _userService.unFriend(event.email);
      _listUser.removeWhere((element) => element.email == event.email);
      _emitFriendLoaded(emit);
    } catch (e) {
      emit(FriendError(message: e.toString()));
    }
  }

  Future<void> _loadMore(Emitter<FriendState> emit) async {
    _isLoading = true;
    _emitFriendLoaded(emit);
    try {
      if (!_hasNext) {
        emit(FriendLoaded(
            listUser: _listUser, isLoading: false, hasNext: false));
        return;
      }
      _pageUser =
          await _userService.getFriendPendingAccept(page: _pageUser.pageNo + 1);
      _hasNext = _pageUser.hasNext;
      _listUser.addAll(_pageUser.items);
      _isLoading = false;
      _emitFriendLoaded(emit);
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
      _isLoading = false;
      _emitFriendLoaded(emit);
    } catch (e) {
      emit(FriendError(message: e.toString()));
    }
  }

  void _clearData() {
    _listUser = [];
    _hasNext = false;
    _isLoading = false;
    _friendsSelectedId = [];
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/friend_request_tab/friend_request_event.dart';
import 'package:map/bloc/friend_request_tab/friend_request_state.dart';
import 'package:map/main.dart';
import 'package:map/service/user_service.dart';

import '../../entity/user_search_response_page.dart';

class FriendRequestBloc extends Bloc<FriendRequestEvent, FriendRequestState> {
  final UserService _userService = getIt<UserService>();
  late UserSearchResponsePage _pageUser;

  FriendRequestBloc() : super(FriendRequestState()) {
    on<InitFriendRequestEvent>((event, emit) async {
      await _init(emit);
    });
    add(InitFriendRequestEvent());
  }

  Future<void> _init(Emitter<FriendRequestState> emit) async {
    emit(FriendRequestLoading());
    try {
      _pageUser = await _userService.getFriendPendingAccept();
      emit(FriendRequestLoaded(pageUser: _pageUser));
    } catch (e) {
      emit(FriendRequestError(message: e.toString()));
    }
  }
}

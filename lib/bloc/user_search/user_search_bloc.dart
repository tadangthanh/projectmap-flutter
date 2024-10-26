import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/user_search/user_search_event.dart';
import 'package:map/bloc/user_search/user_search_state.dart';
import 'package:map/dto/user_search_response.dart';
import 'package:map/main.dart';
import 'package:map/service/user_service.dart';

class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final UserService _userService = getIt<UserService>();
  late List<UserSearchResponse> _users = [];

  UserSearchBloc() : super(UserSearchState()) {
    on<InitialUserSearchEvent>((event, emit) async {
      await _init(emit);
    });
    on<AddFriendEvent>((event, emit) async {
      await _addFriend(event.email, emit);
    });
    on<ExecuteUserSearchEvent>((event, emit) async {
      await _executeSearch(event.email, emit);
    });
    on<UnRequestAddFriendEvent>((event, emit) async {
      await _unRequestAddFriend(event.email, emit);
    });
    on<RejectRequestAddFriendEvent>((event, emit) async {
      await _rejectRequestAddFriend(event.email, emit);
    });
    on<AcceptRequestAddFriendEvent>((event, emit) async {
      await _acceptRequestFriend(event.email, emit);
    });
    add(InitialUserSearchEvent());
  }
  Future<void> _acceptRequestFriend(String email, Emitter<UserSearchState> emit) async {
    emit(LoadingUserSearchState());
    try {
      UserSearchResponse userSearchResponse =  await _userService.acceptFriend(email);
      _users.clear();
      _users.add(userSearchResponse);
      emit(LoadedUserSearchState(_users));
    } catch (e) {
      emit(ErrorUserSearchState(e.toString()));
    }
  }

  Future<void> _rejectRequestAddFriend(String email, Emitter<UserSearchState> emit) async {
    emit(LoadingUserSearchState());
    try {
      UserSearchResponse userSearchResponse =  await _userService.rejectRequestAddFriend(email);
      _users.clear();
      _users.add(userSearchResponse);
      emit(LoadedUserSearchState(_users));
    } catch (e) {
      emit(ErrorUserSearchState(e.toString()));
    }
  }
  Future<void> _unRequestAddFriend(String email, Emitter<UserSearchState> emit) async {
    emit(LoadingUserSearchState());
    try {
      UserSearchResponse userSearchResponse =  await _userService.unRequestAddFriend(email);
      _users.clear();
      _users.add(userSearchResponse);
      emit(LoadedUserSearchState(_users));
    } catch (e) {
      emit(ErrorUserSearchState(e.toString()));
    }
  }
  Future<void>_addFriend(String email, Emitter<UserSearchState> emit) async {
    emit(LoadingUserSearchState());
    try {
      UserSearchResponse userSearchResponse =  await _userService.addFriend(email);
      _users.clear();
      _users.add(userSearchResponse);
      emit(LoadedUserSearchState(_users));
    } catch (e) {
      emit(ErrorUserSearchState(e.toString()));
    }
  }


  Future<void> _executeSearch(
      String email, Emitter<UserSearchState> emit) async {
    emit(LoadingUserSearchState());
    try {
      final user = await _userService.findByEmail(email);
      _users.add(user);
      emit(LoadedUserSearchState([user]));
    } catch (e) {
      emit(ErrorUserSearchState(e.toString()));
    }
  }

  Future<void> _init(Emitter<UserSearchState> emit) async {
    emit(LoadedUserSearchState([]));
  }
}

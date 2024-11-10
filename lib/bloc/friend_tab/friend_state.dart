import '../../dto/user_search_response.dart';

class FriendState {}

class LoadingFriendState extends FriendState {}

class FriendLoaded extends FriendState {
  final List<UserSearchResponse> listUser;
  final List<int> friendsSelectedId;
  final bool isLoading;

  final bool hasNext;

  FriendLoaded(
      {required this.listUser, required this.isLoading, required this.hasNext, this.friendsSelectedId=const []});
}

class FriendError extends FriendState {
  final String message;

  FriendError({this.message = "Error"});
}

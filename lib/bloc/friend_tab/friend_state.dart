import '../../dto/user_search_response.dart';

class FriendState {}
class LoadingFriendState extends FriendState {}
class FriendLoaded extends FriendState {
  final List<UserSearchResponse> listUser;
  final bool isLoading ;
  final bool hasNext;
  FriendLoaded({required this.listUser, required this.isLoading, required this.hasNext});
}
class FriendError extends FriendState{
  final String message;
  FriendError({this.message = "Error"});
}
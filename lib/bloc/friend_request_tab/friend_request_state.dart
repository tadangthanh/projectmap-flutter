import 'package:map/dto/user_search_response.dart';

class FriendRequestState{}
class FriendRequestLoading extends FriendRequestState{}
class FriendRequestLoaded extends FriendRequestState{
  final List<UserSearchResponse> listUser;
  final bool isLoading ;
  final bool hasNext;
  FriendRequestLoaded({required this.listUser, required this.isLoading, required this.hasNext});

}
class FriendRequestError extends FriendRequestState{
  final String message;
  FriendRequestError({this.message = "Error"});
}
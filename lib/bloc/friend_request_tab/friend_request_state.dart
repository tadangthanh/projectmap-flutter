import 'package:map/entity/user_search_response_page.dart';

class FriendRequestState{}
class FriendRequestLoading extends FriendRequestState{}
class FriendRequestLoaded extends FriendRequestState{
  final UserSearchResponsePage pageUser;
  FriendRequestLoaded({required this.pageUser});

}
class FriendRequestError extends FriendRequestState{
  final String message;
  FriendRequestError({this.message = "Error"});
}
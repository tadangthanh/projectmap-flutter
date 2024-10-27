class FriendRequestEvent{}
class InitFriendRequestEvent extends FriendRequestEvent{
}
class LoadMoreFriendRequestEvent extends FriendRequestEvent{
}
class AcceptFriendEvent extends FriendRequestEvent{
  final String email;
  AcceptFriendEvent(this.email);
}
class RejectFriendRequestEvent extends FriendRequestEvent{
  final String email;
  RejectFriendRequestEvent(this.email);
}
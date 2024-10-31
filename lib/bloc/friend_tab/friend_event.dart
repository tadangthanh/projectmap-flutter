class FriendEvent{}
class InitialFriendEvent extends FriendEvent{}
class LoadMoreFriendEvent extends FriendEvent{}
class LoadMoreFriendsEvent extends FriendEvent{}
class UnFriendEvent extends FriendEvent{
  final String email;
  UnFriendEvent(this.email);
}
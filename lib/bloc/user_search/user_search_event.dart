class UserSearchEvent {}
class InitialUserSearchEvent extends UserSearchEvent {}
class ExecuteUserSearchEvent extends UserSearchEvent {
  final String email;
  ExecuteUserSearchEvent(this.email);
}
class AddFriendEvent extends UserSearchEvent {
  final String email;
  AddFriendEvent(this.email);
}
class UnRequestAddFriendEvent extends UserSearchEvent {
  final String email;
  UnRequestAddFriendEvent(this.email);
}
class RejectRequestAddFriendEvent extends UserSearchEvent {
  final String email;
  RejectRequestAddFriendEvent(this.email);
}
class AcceptRequestAddFriendEvent extends UserSearchEvent {
  final String email;
  AcceptRequestAddFriendEvent(this.email);
}
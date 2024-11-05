class GroupListEvent {}
class GroupListInitialEvent extends GroupListEvent {}
class DisbandGroupEvent extends GroupListEvent {
  final int groupId;
  DisbandGroupEvent({required this.groupId});
}
class AcceptJoinGroupEvent extends GroupListEvent {
  final int groupId;
  AcceptJoinGroupEvent({required this.groupId});
}
class RejectJoinGroupEvent extends GroupListEvent {
  final int groupId;
  RejectJoinGroupEvent({required this.groupId});
}
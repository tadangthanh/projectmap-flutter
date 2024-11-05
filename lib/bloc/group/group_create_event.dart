import '../../entity/user.dart';

class GroupCreateEvent{}
class GrcInitEvent extends GroupCreateEvent{}
class GrcAddMemberEvent extends GroupCreateEvent{
    User member;
    GrcAddMemberEvent({required this.member});
}
class GrcRemoveMemberEvent extends GroupCreateEvent{
    User member;
    GrcRemoveMemberEvent({required this.member});
}
class GrcSearchEvent extends GroupCreateEvent{
    String query;
    GrcSearchEvent({required this.query});
}
class GrcCreateGroupEvent extends GroupCreateEvent{
    String groupName;
    String description;
    GrcCreateGroupEvent({required this.groupName, required this.description});
}
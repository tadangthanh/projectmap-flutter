import '../../dto/group_response_dto.dart';

class GroupListState{}
class GroupListLoading extends GroupListState{}
class GroupListError extends GroupListState{
  final String message;
  GroupListError(this.message);
}
class GroupListLoaded extends GroupListState{
  final List<GroupResponseDto> groupsJoined;
  final List<GroupResponseDto> groupsPending;
  GroupListLoaded({required this.groupsJoined, required this.groupsPending});
}
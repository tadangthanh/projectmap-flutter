import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/group/group_list_event.dart';
import 'package:map/bloc/group/group_list_state.dart';
import 'package:map/dto/group_response_dto.dart';
import 'package:map/main.dart';
import 'package:map/service/group_service.dart';

import '../../dto/user_group_status.dart';

class GroupListBloc extends Bloc<GroupListEvent, GroupListState> {
  final GroupService _groupService = getIt<GroupService>();
  late List<GroupResponseDto> groupsJoined = [];
  late List<GroupResponseDto> groupsPending = [];

  GroupListBloc() : super(GroupListState()) {
    on<GroupListInitialEvent>((event, emit) async {
      await _init(emit);
    });
    on<DisbandGroupEvent>((event, emit) async {
      await _disbandGroup(event.groupId, emit);
    });
    on<AcceptJoinGroupEvent>((event, emit) async {
      await _acceptJoinGroup(event.groupId, emit);
    });
    on<RejectJoinGroupEvent>((event, emit) async {
      await _rejectJoinGroup(event.groupId, emit);
    });
    add(GroupListInitialEvent());
  }

  Future<void> _rejectJoinGroup(
      int groupId, Emitter<GroupListState> emit) async {
    emit(GroupListLoading());
    try {
      await _groupService.rejectJoinGroupRequest(groupId);
      groupsPending.removeWhere((element) => element.id == groupId);
      emit(GroupListLoaded(
          groupsJoined: groupsJoined, groupsPending: groupsPending));
    } catch (e) {
      emit(GroupListError(e.toString()));
    }
  }

  Future<void> _acceptJoinGroup(
      int groupId, Emitter<GroupListState> emit) async {
    emit(GroupListLoading());
    try {
      GroupResponseDto result =
          await _groupService.acceptJoinGroupRequest(groupId);
      groupsPending.removeWhere((element) => element.id == groupId);
      groupsJoined.add(result);
      emit(GroupListLoaded(
          groupsJoined: groupsJoined, groupsPending: groupsPending));
    } catch (e) {
      emit(GroupListError(e.toString()));
    }
  }

  Future<void> _disbandGroup(int groupId, Emitter<GroupListState> emit) async {
    emit(GroupListLoading());
    try {
      await _groupService.disbandGroup(groupId);
      groupsJoined.removeWhere((element) => element.id == groupId);
      emit(GroupListLoaded(
          groupsJoined: groupsJoined, groupsPending: groupsPending));
    } catch (e) {
      emit(GroupListError(e.toString()));
    }
  }

  Future<void> _init(Emitter<GroupListState> emit) async {
    emit(GroupListLoading());
    try {
      List<GroupResponseDto> groups = await _groupService.getGroups();
      groupsJoined = groups
          .where((element) => element.status == UserGroupStatus.JOINED)
          .toList();
      groupsPending = groups
          .where((element) => element.status == UserGroupStatus.PENDING)
          .toList();
      emit(GroupListLoaded(
          groupsJoined: groupsJoined, groupsPending: groupsPending));
    } catch (e) {
      emit(GroupListError(e.toString()));
    }
  }
}

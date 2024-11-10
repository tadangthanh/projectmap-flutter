import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/group/group_create_event.dart';
import 'package:map/bloc/group/group_create_state.dart';
import 'package:map/dto/group_request_dto.dart';
import 'package:map/dto/group_response_dto.dart';
import 'package:map/entity/user.dart';
import 'package:map/main.dart';
import 'package:map/service/group_service.dart';
import 'package:map/service/user_service.dart';

class GroupCreateBloc extends Bloc<GroupCreateEvent, GroupCreateState> {
  final UserService _userService = getIt<UserService>();
  final GroupService _groupService = getIt<GroupService>();
  late List<User> _friends;
  late List<User> _selectedMembers=[];

  GroupCreateBloc() : super(GroupCreateState()) {
    on<GrcInitEvent>((event, emit)async {
      await _init(emit);
    });
    on<GrcAddMemberEvent>((event, emit) async {
     await _addMember(event.member, emit);
    });
    on<GrcRemoveMemberEvent>((event, emit) async {
      await _removeMember(event.member, emit);
    });
    on<GrcSearchEvent>((event, emit) async {
      await _searchMember(event.query, emit);
    });
    on<GrcCreateGroupEvent>((event, emit) async {
      await _createGroup(event.groupName,event.description, emit);
    });
    add(GrcInitEvent());
  }

  Future<void> _createGroup(String groupName, String description, Emitter<GroupCreateState> emit) async {
    emit(GrcLoadingState());
    try {
      List<int> userIds = _selectedMembers.map((e) => e.id!).toList();
      GroupRequestDto groupRequestDto = GroupRequestDto(
          name: groupName.trim(),
          description: description.trim(),
          userIds: userIds);
      GroupResponseDto groupResponseDto = await _groupService.createGroup(groupRequestDto);
      emit(GrcSuccessState(groupResponseDto: groupResponseDto));
    } catch (e) {
      emit(GrcErrorState(message: e.toString().split("Exception:").last));
    }
  }


  Future<void> _searchMember(String query, Emitter<GroupCreateState> emit) async {
    String trimmedQuery = query.trim().toLowerCase();

    if (trimmedQuery.isEmpty) {
      emit(GrcLoadedState(friends: _friends, selectedMembers: _selectedMembers));
      return;
    }
    // Sử dụng Set để loại bỏ trùng lặp ngay từ đầu
    Set<User> searchResult = _friends.where((element) {
      return element.name.toLowerCase().contains(trimmedQuery) ||
          element.email.toLowerCase().contains(trimmedQuery);
    }).toSet();

    emit(GrcLoadedState(friends: searchResult.toList(growable: true), selectedMembers: _selectedMembers));
  }


  Future<void> _removeMember(User member,Emitter<GroupCreateState> emit) async {
    if(_selectedMembers.contains(member)) {
      _selectedMembers.remove(member);
    }
    emit(GrcLoadedState(friends: _friends, selectedMembers: _selectedMembers));
  }
  Future<void> _addMember(User member,Emitter<GroupCreateState> emit) async {
    if(!_selectedMembers.contains(member)) {
      _selectedMembers.add(member);
    }
    emit(GrcLoadedState(friends: _friends, selectedMembers: _selectedMembers));
  }

  Future<void> _init(Emitter<GroupCreateState> emit) async {
    _friends = await _userService.getAllFriends();
    emit(GrcLoadedState(friends: _friends, selectedMembers: _selectedMembers));
  }
}

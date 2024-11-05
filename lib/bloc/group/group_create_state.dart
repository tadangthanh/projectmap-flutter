import 'package:map/dto/group_response_dto.dart';
import 'package:map/entity/user.dart';

class GroupCreateState{}
class GrcLoadingState extends GroupCreateState{}
class GrcLoadedState extends GroupCreateState{
    List<User> friends;
    List<User> selectedMembers=[];
    GrcLoadedState({required this.friends, required this.selectedMembers});
}
class GrcErrorState extends GroupCreateState{
    String message;
    GrcErrorState({required this.message});
}
class GrcSuccessState extends GroupCreateState{
    GroupResponseDto groupResponseDto;
    GrcSuccessState({required this.groupResponseDto});
}
import 'package:map/dto/group_request_dto.dart';
import 'package:map/dto/group_response_dto.dart';

import '../util/request.dart';
import '../util/url.dart';

class GroupService {
  Future<GroupResponseDto> createGroup(GroupRequestDto groupRequestDto) async {
    String url = "${Url.BASE_URL_V1}/groups";
    try {
      GroupResponseDto groupResponseDto = GroupResponseDto.fromMap(
          await NetworkService.post(
              url: url,
              headers: {'Content-Type': 'application/json'},
              body: groupRequestDto.toMap()));
      return groupResponseDto;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<GroupResponseDto>> getGroups() async {
    String url = "${Url.BASE_URL_V1}/groups";
    try {
      List<GroupResponseDto> list = GroupResponseDto.fromListJson(
          await NetworkService.get(
              url: url, headers: {'Content-Type': 'application/json'}));
      return list;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> disbandGroup(int id) async {
    String url = "${Url.BASE_URL_V1}/groups/$id";
    try {
      await NetworkService.delete(
          url: url, headers: {'Content-Type': 'application/json'}, body: {});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<GroupResponseDto> acceptJoinGroupRequest(int id) async {
    String url = "${Url.BASE_URL_V1}/groups/$id/accept-join-request";
    try {
      GroupResponseDto result = GroupResponseDto.fromMap(
          await NetworkService.patch(
              url: url,
              headers: {'Content-Type': 'application/json'},
              body: {}));
      return result;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> rejectJoinGroupRequest(int id) async {
    String url = "${Url.BASE_URL_V1}/groups/$id/reject-join-request";
    try {
      await NetworkService.delete(
          url: url,
          headers: {'Content-Type': 'application/json'},
          body: {});
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

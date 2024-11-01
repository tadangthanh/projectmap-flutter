import 'package:geolocator/geolocator.dart';
import 'package:map/dto/page_response.dart';
import 'package:map/dto/user_search_response.dart';
import 'package:map/entity/user.dart';
import 'package:map/main.dart';
import 'package:map/repository/user_repository.dart';
import 'package:map/util/url.dart';

import '../util/request.dart';

class UserService {
  final UserRepository userRepository = getIt<UserRepository>();

  Future<User> saveUser(User user) async {
    await userRepository.deleteUser();
    user.isLocationSharing = true;
    user= await userRepository.saveUser(user);
    // user= await createUser(user);
    return user;
  }

  Future<User?> getUser() async {
    return await userRepository.getUser();
  }

  Future<void> deleteUSer() async {
    return await userRepository.deleteUser();
  }
  // send to backend to save user

  Future<User> createUser(User user) async {
    String url = "${Url.BASE_URL_V1}/users";
    try {
      User createdUser = User.fromMap(await NetworkService.post(url: url, body: user.toMap(), headers: {'Content-Type': 'application/json'}));
      return createdUser;
    } catch (e) {
      // In lỗi để kiểm tra hoặc xử lý thêm
      throw Exception(e.toString());
    }
  }

  Future<UserSearchResponse> findByEmail(String email) async {
    String url = "${Url.BASE_URL_V1}/users/email/$email";
    try {
      UserSearchResponse user = UserSearchResponse.fromMap(await NetworkService.get(url: url, headers: {'Content-Type': 'application/json'}));
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<PageResponse<UserSearchResponse>> getFriendPendingAccept({int page = 0, int size = 10}) async{
    String url = "${Url.BASE_URL_V1}/users/friends/pending/accept?page=$page&size=$size";
    try {
      PageResponse<UserSearchResponse> userSearchResponsePage = PageResponse.fromMap(await NetworkService.get(url: url, headers: {'Content-Type': 'application/json'}),(item)=>UserSearchResponse.fromMap(item));
      return userSearchResponsePage;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<List<User>> getAllFriends() async{
    String url = "${Url.BASE_URL_V1}/users/friends/all";
    try {
      List<User> users = User.fromListJson(await NetworkService.get(url: url, headers: {'Content-Type': 'application/json'}));
      return users;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<PageResponse<UserSearchResponse>> getFriends({int page = 0, int size = 10}) async{
    String url = "${Url.BASE_URL_V1}/users/friends?page=$page&size=$size";
    try {
      PageResponse<UserSearchResponse> userSearchResponsePage = PageResponse.fromMap(await NetworkService.get(url: url, headers: {'Content-Type': 'application/json'}),(item)=>UserSearchResponse.fromMap(item));
      return userSearchResponsePage;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserSearchResponse> addFriend(String email) async{
    String url = "${Url.BASE_URL_V1}/users/add";
    try {
      UserSearchResponse userSearchResponse = UserSearchResponse.fromMap(await NetworkService.post(url: url, body: {'email': email}, headers: {'Content-Type': 'application/json'}));
      return userSearchResponse;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<UserSearchResponse> unRequestAddFriend(String email) async{
    String url = "${Url.BASE_URL_V1}/users/cancel";
    try {
      UserSearchResponse userSearchResponse = UserSearchResponse.fromMap(await NetworkService.delete(url: url, body: {'email': email}, headers: {'Content-Type': 'application/json'}));
      return userSearchResponse;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<UserSearchResponse> rejectRequestAddFriend(String email) async{
    String url = "${Url.BASE_URL_V1}/users/reject";
    try {
      UserSearchResponse userSearchResponse = UserSearchResponse.fromMap(await NetworkService.delete(url: url, body: {'email': email}, headers: {'Content-Type': 'application/json'}));
      return userSearchResponse;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<UserSearchResponse> acceptFriend(String email) async{
    String url = "${Url.BASE_URL_V1}/users/accept";
    try {
      UserSearchResponse userSearchResponse = UserSearchResponse.fromMap(await NetworkService.post(url: url, body: {'email': email}, headers: {'Content-Type': 'application/json'}));
      return userSearchResponse;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateLocationOffline() async {
    String url = "${Url.BASE_URL_V1}/users/update/location/offline";
    Position location = await Geolocator.getCurrentPosition();
    User? user = await getUser();
    if(user!=null){
      user.latitude = location.latitude;
      user.longitude = location.longitude;
      user.speed = location.speed??0;
      await saveUser(user);
      try {
        await NetworkService.post(url: url, body: user.toMap(), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        throw Exception(e.toString());
      }
    }
  }
  Future<void> test() async {
    String url = "${Url.BASE_URL_V1}/users/test";
    try {
      await NetworkService.post(url: url, body: {}, headers: {});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> unFriend(String email) async {
    String url = "${Url.BASE_URL_V1}/users/unfriend";
    try {
      await NetworkService.delete(url: url, body: {'email': email}, headers: {'Content-Type': 'application/json'});
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

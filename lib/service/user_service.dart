import 'dart:convert';

import 'package:map/entity/user.dart';
import 'package:map/main.dart';
import 'package:map/repository/user_repository.dart';
import 'package:map/util/url.dart';
import 'package:http/http.dart' as http;

class UserService {
  final UserRepository userRepository = getIt<UserRepository>();

  Future<User> saveUser(User user) async {
    await userRepository.deleteUser();
    user.isLocationSharing = true;
    user= await userRepository.saveUser(user);
    user= await createUser(user);
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
    String url = "${Url.BASE_URL}/users";
    try {
      // Encode Map<String, dynamic> thành JSON string
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // Đặt header cho content-type là JSON
        },
        body: user.toJson(), // Chuyển đối tượng User thành chuỗi JSON
      );

      if (response.statusCode == 200) {
        // Phân tích dữ liệu phản hồi khi thành công
        var responseData = jsonDecode(response.body);
        if(responseData['status'] != 201){
          throw Exception("Failed to create user: ${responseData['message']}");
        }
        // Tạo đối tượng User từ phản hồi của server
        User createdUser = User.fromMap(responseData['data']);
        return createdUser;
      } else {
        // Phân tích phản hồi khi có lỗi
        var errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Unknown error occurred';
        // Ném ra ngoại lệ với thông điệp lỗi từ phản hồi
        throw Exception("Failed to create user: $errorMessage");
      }
    } catch (e) {
      // In lỗi để kiểm tra hoặc xử lý thêm
      throw Exception(e.toString());
    }
  }

}

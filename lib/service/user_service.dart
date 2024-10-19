import 'package:map/entity/user.dart';
import 'package:map/main.dart';
import 'package:map/repository/user_repository.dart';

class UserService {
  final UserRepository userRepository = getIt<UserRepository>();

  Future<User> saveUser(User user) async {
    await userRepository.deleteUser();
    return await userRepository.saveUser(user);
  }
  Future<User?> getUser() async {
    return await userRepository.getUser();
  }
  Future<void> deleteUSer()async{
    return await userRepository.deleteUser();
  }
}

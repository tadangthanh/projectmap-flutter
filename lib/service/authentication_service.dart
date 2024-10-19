import 'package:google_sign_in/google_sign_in.dart';
import 'package:map/entity/user.dart';
import 'package:map/service/sql_service.dart';
import 'package:map/service/user_service.dart';

import '../main.dart';

class AuthenticationService {
  final SqliteService sqliteService = getIt<SqliteService>();
  final UserService userService = getIt<UserService>();

  Future<User?> getUser() async {
    return await userService.getUser();
  }

  Future<User> loginWithGoogle(GoogleSignInAccount? googleSignInAccount) async {
    if (googleSignInAccount == null) {
      throw Exception('Đăng nhập thất bại, vui lòng thử lại sau! ');
    }
    User user = User(
        googleSignInAccount.displayName ??
            googleSignInAccount.email.split("@").first,
        googleSignInAccount.id,
        googleSignInAccount.email,
        googleSignInAccount.photoUrl ?? '',
        true);
    return await userService.saveUser(user);
  }
}

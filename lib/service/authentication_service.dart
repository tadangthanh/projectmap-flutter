import 'package:google_sign_in/google_sign_in.dart';
import 'package:map/entity/user.dart';
import 'package:map/repository/token_repository.dart';
import 'package:map/service/sql_service.dart';
import 'package:map/service/user_service.dart';
import 'package:map/util/request.dart';

import '../entity/token_response.dart';
import '../main.dart';
import '../util/url.dart';

class AuthenticationService {
  final SqliteService sqliteService = getIt<SqliteService>();
  final UserService userService = getIt<UserService>();
  final TokenRepo tokenRepo = getIt<TokenRepo>();

  Future<User?> getUser() async {
    return await userService.getUser();
  }

  Future<User> loginWithGoogle(GoogleSignInAccount? googleSignInAccount) async {
    if (googleSignInAccount == null) {
      throw Exception('Đăng nhập thất bại, vui lòng thử lại sau!');
    }
    // Lấy thông tin xác thực của người dùng
    GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;
    // Lấy ID Token
    String? idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception('Đăng nhập thất bại, vui lòng thử lại sau!');
    }
    try {
      User user = User(
          googleSignInAccount.displayName ??
              googleSignInAccount.email.split("@").first,
          googleSignInAccount.id,
          googleSignInAccount.email,
          googleSignInAccount.photoUrl ?? '',
          true,
          100,
          0.0,
          0.0,
          0.0,
          0.0);
      TokenResponse tokenResponse = await authentication(idToken);
      await tokenRepo.saveToken(tokenResponse);
      await userService.saveUser(user);
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // authentication with google, neu ng dung chua co trong csdl thi se tao moi
  Future<TokenResponse> authentication(String idToken) async {
    String url = "${Url.BASE_URL}/auth/google";
    try {
      final Map<String, String> headers = {'X-ID-TOKEN': idToken};
      TokenResponse tokenResponse = TokenResponse.fromMap(
          await await NetworkService.post(
              url: url, headers: headers, body: null));
      return tokenResponse;
    } catch (e) {
      // In lỗi để kiểm tra hoặc xử lý thêm
      throw Exception(e.toString());
    }
  }
}

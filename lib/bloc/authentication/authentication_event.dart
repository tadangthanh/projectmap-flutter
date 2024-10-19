import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationEvent{}
class InitAuthenticationEvent extends AuthenticationEvent{}
class LoginEvent extends AuthenticationEvent{
  GoogleSignInAccount? user;
  LoginEvent(this.user);
}

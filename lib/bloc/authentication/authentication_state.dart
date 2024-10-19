import 'package:map/entity/user.dart';

class AuthenticationState{}
class PendingLoginState extends AuthenticationState{}
class  LoadingLoginState extends AuthenticationState{}
class LoadedLoginState extends AuthenticationState{
  final User user;
  LoadedLoginState(this.user);
}
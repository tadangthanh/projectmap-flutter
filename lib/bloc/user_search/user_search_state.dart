import 'package:map/dto/user_search_response.dart';

class UserSearchState{}
class LoadingUserSearchState extends UserSearchState{}
class LoadedUserSearchState extends UserSearchState{
  final List<UserSearchResponse> users;
  LoadedUserSearchState(this.users);
}
class ErrorUserSearchState extends UserSearchState{
  final String message;
  ErrorUserSearchState(this.message);
}
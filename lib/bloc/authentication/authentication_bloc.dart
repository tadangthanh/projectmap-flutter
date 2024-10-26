import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/authentication/authentication_event.dart';
import 'package:map/bloc/authentication/authentication_state.dart';
import 'package:map/entity/user.dart';
import 'package:map/service/authentication_service.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationService _authenticationService = AuthenticationService();

  AuthenticationBloc() : super(AuthenticationState()) {
    on<InitAuthenticationEvent>((event, emit) async {
      await _init(emit);
    });
    on<LoginEvent>((event, emit) async {
      await _login(event, emit);
    });
    add(InitAuthenticationEvent());
  }

  Future<void> _init(Emitter<AuthenticationState> emit) async {
    emit(LoadingLoginState());
    User? user = await _authenticationService.getUser();
    if (user == null) {
      emit(PendingLoginState());
    } else {
      emit(LoadedLoginState(user));
    }
  }
  Future<void> _login(LoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(LoadingLoginState());
   try{

     User user = await _authenticationService.loginWithGoogle(event.user);
     emit(LoadedLoginState(user));
   }catch (e){
      emit(ErrorLoginState(e.toString()));
      return;
   }
  }
}

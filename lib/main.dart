import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:map/bloc/authentication/authentication_bloc.dart';
import 'package:map/bloc/authentication/authentication_event.dart';
import 'package:map/bloc/authentication/authentication_state.dart';
import 'package:map/home_screen.dart';
import 'package:map/repository/location_search_history_repository.dart';
import 'package:map/repository/token_repository.dart';
import 'package:map/repository/user_repository.dart';
import 'package:map/service/authentication_service.dart';
import 'package:map/service/location_search_history_service.dart';
import 'package:map/service/place_search.dart';
import 'package:map/service/sql_service.dart';
import 'package:map/service/user_service.dart';

final getIt = GetIt.instance;

void main() {
  getIt.registerLazySingleton<SqliteService>((() => SqliteService()));
  getIt.registerLazySingleton<UserRepository>((() => UserRepository()));
  getIt.registerLazySingleton<UserService>((() => UserService()));
  getIt.registerLazySingleton<PlaceSearch>((() => PlaceSearch()));
  getIt.registerLazySingleton<LocationSearchHistoryRepo>((() => LocationSearchHistoryRepo()));
  getIt.registerLazySingleton<LocationSearchHistoryService>((() => LocationSearchHistoryService()));
  getIt.registerLazySingleton<TokenRepo>((() => TokenRepo()));
  getIt.registerLazySingleton<AuthenticationService>(
      (() => AuthenticationService()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTogether',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'openid', // Phạm vi để yêu cầu idToken
      'profile', // Để lấy thông tin người dùng như tên và ảnh đại diện
    ],
  );
  final AuthenticationBloc _authenticationBloc = AuthenticationBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _authenticationBloc,
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
          if (state is PendingLoginState) {
            return Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bạn chưa đăng nhập"),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  onPressed: () async {
                    _googleSignIn.signOut();
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(LoginEvent(await _googleSignIn.signIn()));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 25,
                        child: Image.asset("assets/icons/google.png"),
                      ),
                      const Text("Đăng nhập bằng Google")
                    ],
                  ),
                )
              ],
            ));
          }else if(state is LoadingLoginState){
            return const Center(child: CircularProgressIndicator());
          }else if(state is ErrorLoginState){
            return AlertDialog(
              title: const Text("Đăng nhập thất bại"),
              content: Text(state.message),
              actions: [
                TextButton(
                    onPressed: () async {
                      BlocProvider.of<AuthenticationBloc>(context)
                          .add(InitAuthenticationEvent());
                    },
                    child: const Text("OK"))
              ],
            );
          }
          return  HomePage();
        }),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _authenticationBloc.close();
  }
}

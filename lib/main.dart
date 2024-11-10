import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
import 'package:map/service/back_service.dart';
import 'package:map/service/custome_sound_notification.dart';
import 'package:map/service/firebase_api.dart';
import 'package:map/service/group_service.dart';
import 'package:map/service/location_search_history_service.dart';
import 'package:map/service/notification_service.dart';
import 'package:map/service/place_search.dart';
import 'package:map/service/shared_location_service.dart';
import 'package:map/service/sql_service.dart';
import 'package:map/service/user_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerLazySingleton<SqliteService>((() => SqliteService()));
  getIt.registerLazySingleton<UserRepository>((() => UserRepository()));
  getIt.registerLazySingleton<BackendService>((() => BackendService()));
  getIt.registerLazySingleton<UserService>((() => UserService()));
  getIt.registerLazySingleton<PlaceSearch>((() => PlaceSearch()));
  getIt.registerLazySingleton<LocationSearchHistoryRepo>((() => LocationSearchHistoryRepo()));
  getIt.registerLazySingleton<LocationSearchHistoryService>((() => LocationSearchHistoryService()));
  getIt.registerLazySingleton<TokenRepo>((() => TokenRepo()));
  getIt.registerLazySingleton<NotificationApiService>((() => NotificationApiService()));
  getIt.registerLazySingleton<NotificationLocalService>((() => NotificationLocalService()));
  getIt.registerLazySingleton<GroupService>((() => GroupService()));
  getIt.registerLazySingleton<SharedLocationService>((() => SharedLocationService()));
  getIt.registerLazySingleton<AuthenticationService>(
      (() => AuthenticationService()));


  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await Permission.ignoreBatteryOptimizations.request();
  // Kiểm tra trạng thái dịch vụ
  final service = FlutterBackgroundService();
  bool isRunning = await service.isRunning();

  // Chỉ khởi tạo nếu dịch vụ chưa chạy
  if (!isRunning) {
    BackendService backendService = getIt<BackendService>();
    await backendService.initializedService();
  }
  // await Workmanager().cancelAll(); // Hủy công việc trước đó nếu có
  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  // Workmanager().registerOneOffTask(
  //   constraints: Constraints(
  //     networkType: NetworkType.connected,
  //   ),
  //   "1",
  //   "foregroundServiceTask",
  //   // frequency: const Duration(minutes: 15), // Chạy mỗi giờ
  //    // Chạy ngay sau khi đăng ký
  //   initialDelay: const Duration(seconds: 15),
  // );

  await Firebase.initializeApp();
  // config thong bao
  FirebaseApi().initNotification();

  runApp(const MyApp());
}
@pragma('vm:entry-point')
void callbackDispatcher() {
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<SqliteService>((() => SqliteService()));
  getIt.registerLazySingleton<UserRepository>((() => UserRepository()));
  getIt.registerLazySingleton<BackendService>((() => BackendService()));
  getIt.registerLazySingleton<UserService>((() => UserService()));
  getIt.registerLazySingleton<PlaceSearch>((() => PlaceSearch()));
  getIt.registerLazySingleton<LocationSearchHistoryRepo>((() => LocationSearchHistoryRepo()));
  getIt.registerLazySingleton<LocationSearchHistoryService>((() => LocationSearchHistoryService()));
  getIt.registerLazySingleton<TokenRepo>((() => TokenRepo()));
  getIt.registerLazySingleton<AuthenticationService>(
      (() => AuthenticationService()));
  Workmanager().executeTask((task, inputData) async {
    if(inputData!=null){
      final UserService userService = getIt<UserService>();
      await userService.updateLocationOffline();
      await userService.test();
    }else{
      print("-------------------------------------------------No data");
    }
    // Bắt đầu foreground service
    // final service = FlutterBackgroundService();
    // await service.startService();
    // service.invoke("setAsForeground"); // Chạy foreground service khi được kích hoạt

    // Dừng foreground service sau khi thực hiện xong
    // Timer(Duration(seconds: 10), () { // Dừng service sau 5 phút (hoặc thời gian tùy chọn)
    //   service.invoke("stopService");
    // });

    return Future.value(true);
  });
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _authenticationBloc.close();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:map/repository/token_repository.dart';
import 'package:map/service/place_search.dart';
import 'package:map/service/sql_service.dart';
import 'package:map/service/user_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../repository/location_search_history_repository.dart';
import '../repository/user_repository.dart';
import 'authentication_service.dart';
import 'location_search_history_service.dart';
class BackendService {
  Future<void> initializedService() async {
    final service = FlutterBackgroundService();
    await service.configure(iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground
    ),
        androidConfiguration: AndroidConfiguration(
            onStart: onStart,
            isForegroundMode: true,
            autoStart:false,
            autoStartOnBoot: false,

        ));
  }
  Future<void> startService() async {
    final service = FlutterBackgroundService();
    if (!(await service.isRunning())) {
      service.startService(); // Khởi động dịch vụ nếu chưa chạy
    }
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('stopService'); // Gửi sự kiện để dừng dịch vụ
    }
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service)async {
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<SqliteService>((() => SqliteService()));
  getIt.registerLazySingleton<UserRepository>((() => UserRepository()));
  getIt.registerLazySingleton<UserService>((() => UserService()));
  getIt.registerLazySingleton<PlaceSearch>((() => PlaceSearch()));
  getIt.registerLazySingleton<LocationSearchHistoryRepo>((() => LocationSearchHistoryRepo()));
  getIt.registerLazySingleton<LocationSearchHistoryService>((() => LocationSearchHistoryService()));
  getIt.registerLazySingleton<TokenRepo>((() => TokenRepo()));
  getIt.registerLazySingleton<AuthenticationService>(
      (() => AuthenticationService()));

  UserService userService = getIt<UserService>();
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on("setAsForeground").listen((event) {
      service.setAsForegroundService();
    });
    service.on("setAsBackground").listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  // final TokenRepo _tokenRepo = getIt<TokenRepo>();
  // final _tokenResponse = await _tokenRepo.getToken();
  // final _user = await userService.getUser();
  //
  // final StompClient _client=StompClient(
  //     config: StompConfig(
  //       url: "ws://192.168.1.242:8080/ws?token=${_tokenResponse?.accessToken}",
  //       onConnect: (frame){},
  //       onWebSocketError: (dynamic error) =>
  //       throw Exception("error connect $error"),
  //     ));
  // _client.activate();
  //


  // Timer.periodic(Duration(seconds: 1), (timer) async {
  //   if (service is AndroidServiceInstance) {
  //     if (await service.isForegroundService()) {
  //       service.setForegroundNotificationInfo(
  //           title: "Đang chia sẻ vị trí", content: "Ứng dụng đang chia sẻ vị trí của bạn");
  //     }
  //   }
  //   print("background service is running");
  //   Position location = await Geolocator.getCurrentPosition();
  //
  //   _user?.latitude = location.latitude;
  //   _user?.longitude = location.longitude;
  //   _user?.speed = location.speed??0;
  //   _client.send(
  //       destination: '/app/on-move',
  //       headers: {
  //         'Content-type': 'application/json', // Đặt tiêu đề là JSON
  //         'Authorization': 'Bearer ${_tokenResponse?.accessToken}'
  //       },
  //       body: jsonEncode(_user?.toMap()));
  //
  //   // await userService.test();
  //   // service.invoke("stopService");
  //   // service.stopSelf();
  //   // print("Location: ${location.latitude} - ${location.longitude}");
  //   service.invoke("update");
  // });
}
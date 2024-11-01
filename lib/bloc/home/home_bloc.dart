import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/home/home_event.dart';
import 'package:map/bloc/home/home_state.dart';
import 'package:map/service/custome_sound_notification.dart';
import 'package:map/service/notification_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../entity/token_response.dart';
import '../../main.dart';
import '../../repository/token_repository.dart';

class HomeBloc extends Bloc<HomeEvent,HomeState> {
  final TokenRepo _tokenRepo = getIt<TokenRepo>();
  final NotificationLocalService _notificationLocalService = getIt<NotificationLocalService>();
  final NotificationApiService _notificationApiService = getIt<NotificationApiService>();
  late TokenResponse? _tokenResponse = null;
  late StompClient _client;
  late int _notificationUnreadCount = 0;


  HomeBloc() : super(HomeState()) {
    on<HomeInitEvent>((event, emit) async {
     await _init(emit);
    });
    add(HomeInitEvent());
  }

  Future<void> _init(Emitter<HomeState> emit) async {
    // init data for websocket
    try{
      emit(HomeLoadingState());
      _tokenResponse = await _tokenRepo.getToken();
      _notificationUnreadCount = await _notificationApiService.countUnreadNotification();
      _initWebsocket();
      emit(HomeLoadedState(notificationUnreadCount: _notificationUnreadCount));
    }catch(e){
      emit(HomeErrorState(e.toString()));
    }
  }

  void _initWebsocket() {
    _client = StompClient(
      config: StompConfig(
        url: "ws://192.168.1.242:8080/ws?token=${_tokenResponse?.accessToken}",
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) {
          print("WebSocket Error: $error");
          _retryConnection(); // Hàm để thực hiện kết nối lại
        },
        onDisconnect: (frame) {
          print("WebSocket Disconnected");
          _retryConnection(); // Thực hiện kết nối lại khi bị mất kết nối
        },
      ),
    );
    _client.activate();
  }

  void _onConnect(StompFrame frame) {
    if (_client.isActive) {
      _client.subscribe(
        headers: {'Authorization': 'Bearer ${_tokenResponse?.accessToken}'},
        destination: '/user/private/notifications',
        callback: onListenWs,
      );
    } else {
      print("Cannot subscribe because connection is not active.");
    }
  }

  void _retryConnection() {
    Future.delayed(const Duration(seconds: 5), () {
      print("Attempting to reconnect...");
      _client.activate(); // Kích hoạt lại client để kết nối
    });
  }

  void onListenWs(StompFrame frame) async {
    if (frame.body != null) {
      print('--------------------------------------------frame ${frame.body}');
      // Thực hiện logic cập nhật danh sách thông báo từ frame nhận được
      // Bạn có thể parse JSON từ frame.body nếu cần
    }
  }
}
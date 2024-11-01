import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/notification/notification_event.dart';
import 'package:map/bloc/notification/notification_state.dart';
import 'package:map/dto/notification.dart';
import 'package:map/dto/page_response.dart';

import '../../main.dart';
import '../../service/notification_service.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationApiService _notificationApiService =getIt<NotificationApiService>();

  late PageResponse<NotificationDto> _pageNotification;
  late List<NotificationDto> _listNotification;
  late bool _hasNext = false;

  NotificationBloc() : super(NotificationState()) {
    on<NotificationInitEvent>((event, emit) async {
      await _init(emit);
    });
    on<LoadMoreNotificationsEvent>((event, emit) async {
      await _loadMore(emit);
    });
    on<MarkAllNotificationsAsReadEvent>((event, emit) async {
      await _markAllNotificationAsRead(emit);
    });
    on<DeleteAllNotificationsEvent>((event, emit) async {
      await _deleteAllNotification(emit);
    });
    on<MarkNotificationAsReadEvent>((event, emit) async {
      await _markNotificationAsRead(emit, event.notificationId);
    });
    add(NotificationInitEvent());
  }

  Future<void> _markNotificationAsRead(
      Emitter<NotificationState> emit, int notificationId) async {
    try {
      await _notificationApiService.markAsRead(notificationId);
      for (var element in _listNotification) {
        if (element.id == notificationId) {
          element.isRead = true;
          break;
        }
      }
      emit(NotificationLoadedState(
          notifications: _listNotification,
          hasNext: _hasNext,
          isLoading: false));
    } catch (e) {
      emit(NotificationErrorState(e.toString()));
    }
  }



  Future<void>_deleteAllNotification(Emitter<NotificationState> emit) async {
    try {
      await _notificationApiService.deleteAllNotification();
      _listNotification.clear();
      emit(NotificationLoadedState(
          notifications: _listNotification,
          hasNext: _hasNext,
          isLoading: false));
    } catch (e) {
      emit(NotificationErrorState(e.toString()));
    }
  }

  Future<void> _markAllNotificationAsRead(
      Emitter<NotificationState> emit) async {
    try {
      await _notificationApiService.markAsReadAll();
      for (var element in _listNotification) {
        element.isRead = true;
      }
      emit(NotificationLoadedState(
          notifications: _listNotification,
          hasNext: _hasNext,
          isLoading: false));
    } catch (e) {
      emit(NotificationErrorState(e.toString()));
    }
  }

  Future<void> _loadMore(Emitter<NotificationState> emit) async {
    emit(NotificationLoadedState(
        notifications: _listNotification, isLoading: true, hasNext: _hasNext));
    try {
      if (!_hasNext) {
        emit(NotificationLoadedState(
            notifications: _listNotification,
            isLoading: false,
            hasNext: false));
        return;
      }
      _pageNotification = await _notificationApiService.getNotifications(
          page: _pageNotification.pageNo + 1);
      _hasNext = _pageNotification.hasNext;
      _listNotification.addAll(_pageNotification.items);
      emit(NotificationLoadedState(
          notifications: _listNotification,
          isLoading: false,
          hasNext: _hasNext));
    } catch (e) {
      emit(NotificationErrorState(e.toString()));
    }
  }

  Future<void> _init(Emitter<NotificationState> emit) async {
    emit(NotificationLoadingState());
    try {
      // init data for notification
      _clearData();
      _pageNotification = await _notificationApiService.getNotifications();
      _hasNext = _pageNotification.hasNext;
      _listNotification = _pageNotification.items;

      emit(NotificationLoadedState(
          notifications: _listNotification,
          isLoading: false,
          hasNext: _hasNext));
    } catch (e) {
      emit(NotificationErrorState(e.toString()));
    }
  }

  void _clearData() {
    _listNotification = [];
    _hasNext = false;
  }

}

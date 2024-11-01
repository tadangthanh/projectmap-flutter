import 'package:map/dto/notification.dart';
import 'package:map/dto/page_response.dart';

import '../util/request.dart';
import '../util/url.dart';

class NotificationApiService{
  Future<PageResponse<NotificationDto>> getNotifications({int page = 0, int size = 10}) async{
    String url = "${Url.BASE_URL_V1}/notifications?page=$page&size=$size";
    try {
      PageResponse<NotificationDto> notifications = PageResponse.fromMap(await NetworkService.get(url: url, headers: {'Content-Type': 'application/json'}), (item) => NotificationDto.fromJson(item));
      return notifications;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<void> markAsReadAll() async{
    String url = "${Url.BASE_URL_V1}/notifications/mark-as-read/all";
    try {
      await NetworkService.put(url: url, headers: {},body: {});
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<void> deleteAllNotification() async {
    String url = "${Url.BASE_URL_V1}/notifications/delete/all";
    try {
      await NetworkService.delete(url: url, headers: {}, body: {});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<NotificationDto> markAsRead(int notificationId) async {
    String url = "${Url.BASE_URL_V1}/notifications/$notificationId/mark-as-read";
    try {
      NotificationDto notification = NotificationDto.fromJson(await NetworkService.patch(url: url, headers: {}, body: {}));
      return notification;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<int> countUnreadNotification() async {
    String url = "${Url.BASE_URL_V1}/notifications/count-unread";
    try {
      int count = await NetworkService.get(url: url, headers: {});
      return count;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
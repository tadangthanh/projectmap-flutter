import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationLocalService {

  NotificationLocalService() {
    setupNotification();
  }
// Cấu hình thông báo tùy chỉnh
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void setupNotification() {
    const InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showCustomNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'notification_channel_id',
            'notification_channel_name',
            sound: RawResourceAndroidNotificationSound('notification'), // Sử dụng âm thanh tùy chỉnh
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

}
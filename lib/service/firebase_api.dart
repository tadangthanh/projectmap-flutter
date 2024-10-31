import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:map/service/custome_sound_notification.dart';

class FirebaseApi{

 final _firebaseMessaging = FirebaseMessaging.instance;
 final NotificationService _notificationService = NotificationService();


 Future<void> initNotification() async{
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _notificationService.showCustomNotification(message);
    });
 }
}
import 'notification_type.dart';

class NotificationDto{
   int id;
   String title;
   String message;
   bool isRead;
   NotificationType type;
   String? recipientGoogleId;
   String? senderGoogleId;
   int? groupId;

    NotificationDto({
      required this.id,
      required this.title,
      required this.message,
      required this.isRead,
      required this.type,
      this.recipientGoogleId,
      this.senderGoogleId,
      this.groupId,
    });

    factory NotificationDto.fromJson(Map<String, dynamic> json) {
      return NotificationDto(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        isRead: json['isRead'],
        type: NotificationType.values[json['type']],
        recipientGoogleId: json['recipientGoogleId'],
        senderGoogleId: json['senderGoogleId'],
        groupId: json['groupId'],
      );
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['title'] = this.title;
      data['message'] = this.message;
      data['isRead'] = this.isRead;
      data['type'] = this.type.index;
      data['recipientGoogleId'] = this.recipientGoogleId;
      data['senderGoogleId'] = this.senderGoogleId;
      data['groupId'] = this.groupId;
      return data;
    }
}
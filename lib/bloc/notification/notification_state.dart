import '../../dto/notification.dart';

class NotificationState{}
class NotificationLoadingState extends NotificationState{}
class NotificationLoadedState extends NotificationState{
  final bool hasNext;
  final List<NotificationDto> notifications;
  NotificationLoadedState(this.hasNext, this.notifications);
}
class NotificationErrorState extends NotificationState{
  final String message;
  NotificationErrorState(this.message);
}
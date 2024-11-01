import '../../dto/notification.dart';

class NotificationState{}
class NotificationLoadingState extends NotificationState{}
class NotificationLoadedState extends NotificationState{
  final bool hasNext;
  final List<NotificationDto> notifications;
  final bool isLoading;
  NotificationLoadedState({required this.notifications, required this.hasNext, required this.isLoading});
}
class NotificationErrorState extends NotificationState{
  final String message;
  NotificationErrorState(this.message);
}
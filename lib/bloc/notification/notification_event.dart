class NotificationEvent {}
class NotificationInitEvent extends NotificationEvent{}
class RefreshNotificationsEvent extends NotificationEvent{}
class LoadMoreNotificationsEvent extends NotificationEvent{}
class MarkNotificationAsReadEvent extends NotificationEvent{
  final int notificationId;
  MarkNotificationAsReadEvent(this.notificationId);
}
class MarkAllNotificationsAsReadEvent extends NotificationEvent{}
class DeleteAllNotificationsEvent extends NotificationEvent{}
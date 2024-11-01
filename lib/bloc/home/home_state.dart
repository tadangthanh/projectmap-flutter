class HomeState {}

class HomeLoadedState extends HomeState {
  final int notificationUnreadCount;
  HomeLoadedState({required this.notificationUnreadCount});
}
class HomeLoadingState extends HomeState {}

class HomeErrorState extends HomeState {
  final String message;
  HomeErrorState(this.message);
}
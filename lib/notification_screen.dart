import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map/common_view/loading.dart';
import 'package:map/friend_list_tab.dart';

import 'bloc/notification/notification_bloc.dart';
import 'bloc/notification/notification_event.dart';
import 'bloc/notification/notification_state.dart';
import 'dto/notification_type.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotificationScreenState();
  }
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationBloc _notificationBloc = NotificationBloc();
  final ScrollController _scrollController = ScrollController();
  bool _showNoMoreNotifications = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(loadMoreData);
    _notificationBloc.add(NotificationInitEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadMoreData() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_showNoMoreNotifications) {
        _notificationBloc.add(LoadMoreNotificationsEvent());
      }
    }
  }

  Future<void> _refreshData() async {
    _notificationBloc.add(NotificationInitEvent());
    if (!_scrollController.hasListeners) {
      _scrollController.addListener(loadMoreData);
    }
    setState(() {
      _showNoMoreNotifications = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _notificationBloc,
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoadingState) {
            return loading();
          } else if (state is NotificationLoadedState) {
            if (!state.hasNext) {
              _scrollController.removeListener(loadMoreData);
              _showNoMoreNotifications = true;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.more_horiz_outlined, color: Colors.grey),
                            onPressed: () {
                              showMenu(
                                context: context,
                                position: const RelativeRect.fromLTRB(10, 150, 5, 0),
                                items: [
                                  PopupMenuItem<int>(
                                    value: 0,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.mark_as_unread_outlined, color: Colors.blueAccent),
                                          title: const Text('Đánh dấu tất cả là đã đọc'),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _notificationBloc.add(MarkAllNotificationsAsReadEvent());
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.cancel_presentation, color: Colors.red),
                                          title: const Text('Xóa hết thông báo'),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _notificationBloc.add(DeleteAllNotificationsEvent());
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                                elevation: 8.0,
                              );
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshData,
                          child: _builderListNotification(context, state),
                        ),
                      ),
                    ],
                  ),
                  if (state.isLoading)
                    const Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SpinKitWave(
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else if (state is NotificationErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _builderListNotification(context, state) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.notifications.length + (_showNoMoreNotifications ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.notifications.length) {
          final notification = state.notifications[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: notification.isRead ? 0 : 4,
            color: notification.isRead ? Colors.grey.shade200 : Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: notification.senderAvatarUrl != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(notification.senderAvatarUrl),
                radius: 30,
              )
                  : const Icon(Icons.notifications_outlined),
              title: Text(
                "${notification.title}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.w600,
                  color: notification.isRead
                      ? Colors.black.withOpacity(0.6)
                      : Colors.black,
                ),
              ),
              subtitle: Text(
                notification.message,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: notification.isRead ? Colors.grey : Colors.black87,
                ),
              ),
              onTap: () {
                if (!notification.isRead) {
                  _notificationBloc.add(MarkNotificationAsReadEvent(notification.id));
                }
                if (notification.type == NotificationType.FRIEND_REQUEST) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FriendListTabScreen(
                            selectedIndex: 1,
                          )));
                } else if (notification.type == NotificationType.ACCEPT_FRIEND) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FriendListTabScreen(
                            selectedIndex: 0,
                          )));
                }
              },
            ),
          );
        } else {
          return Visibility(
            visible: _showNoMoreNotifications,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Không còn thông báo nào',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

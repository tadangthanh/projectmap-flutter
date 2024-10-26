import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/friend_request_tab/friend_request_bloc.dart';
import 'package:map/bloc/friend_request_tab/friend_request_state.dart';

class FriendRequestsTab extends StatelessWidget {
  final bool isLoading = false; // Placeholder để mô phỏng việc tải dữ liệu
  final FriendRequestBloc _friendRequestBloc = FriendRequestBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _friendRequestBloc,
        child: BlocBuilder<FriendRequestBloc, FriendRequestState>(
            builder: (context, state) {
          if (state is FriendRequestLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FriendRequestLoaded) {
            return Padding(
              padding: const EdgeInsets.only(
                  top: 16, left: 16, right: 16, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lời mời kết bạn',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          itemCount: state.pageUser.items.length,
                          // Placeholder for number of friend requests
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: Key('request_$index'),
                              direction: DismissDirection.horizontal,
                              onDismissed: (direction) {
                                // Xử lý xóa lời mời kết bạn
                              },
                              background: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerLeft,
                                color: Colors.green.withOpacity(0.8),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 30),
                              ),
                              secondaryBackground: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerRight,
                                color: Colors.red.withOpacity(0.8),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 30),
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        state.pageUser.items[index].avatarUrl),
                                    child: null,
                                  ),
                                  title: Text(
                                    state.pageUser.items[index].name,
                                    style:
                                        const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(state.pageUser.items[index].email,),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green),
                                        onPressed: () {
                                          // Xử lý khi người dùng nhấn chấp nhận
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () {
                                          // Xử lý khi người dùng nhấn từ chối
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (isLoading)
                          const Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('Error'));
        }));
  }
}

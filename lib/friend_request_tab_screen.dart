import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:map/bloc/friend_request_tab/friend_request_bloc.dart';
import 'package:map/bloc/friend_request_tab/friend_request_state.dart';
import 'bloc/friend_request_tab/friend_request_event.dart';

class FriendRequestTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FriendRequestTabState();
  }
}

class _FriendRequestTabState extends State<FriendRequestTab> {
  final FriendRequestBloc _friendRequestBloc = FriendRequestBloc();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(loadMoreData);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadMoreData() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _friendRequestBloc.add(LoadMoreFriendRequestEvent());
    }
  }

  Future<void> _refreshData() async {
    _friendRequestBloc.add(InitFriendRequestEvent());
    _scrollController.addListener(loadMoreData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _friendRequestBloc,
        child: BlocBuilder<FriendRequestBloc, FriendRequestState>(
            builder: (context, state) {
          if (state is FriendRequestLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FriendRequestLoaded) {
            if (!state.hasNext) {
              _scrollController.removeListener(loadMoreData);
            }
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
                        RefreshIndicator(
                          onRefresh: _refreshData,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.listUser.length,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                key: Key('request_$index'),
                                direction: DismissDirection.horizontal,
                                onDismissed: (direction) {
                                  // Phân biệt giữa vuốt sang phải và vuốt sang trái
                                  if (direction == DismissDirection.startToEnd) {
                                    // Vuốt từ trái sang phải: Chấp nhận lời mời
                                    BlocProvider.of<FriendRequestBloc>(context)
                                        .add(AcceptFriendEvent(
                                        state.listUser[index].email));
                                  } else if (direction == DismissDirection.endToStart) {
                                    // Vuốt từ phải sang trái: Từ chối lời mời
                                    BlocProvider.of<FriendRequestBloc>(context)
                                        .add(RejectFriendRequestEvent(
                                        state.listUser[index].email));
                                  }
                                },
                                background: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  alignment: Alignment.centerLeft,
                                  color: Colors.green.withOpacity(0.8),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.white, size: 30),
                                      SizedBox(width: 8),
                                      Text("Vuốt để chấp nhận", style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                secondaryBackground: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  alignment: Alignment.centerRight,
                                  color: Colors.red.withOpacity(0.8),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("Vuốt để từ chối", style: TextStyle(color: Colors.white)),
                                      SizedBox(width: 8),
                                      Icon(Icons.close, color: Colors.white, size: 30),
                                    ],
                                  ),
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 3,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          state.listUser[index].avatarUrl),
                                      child: null,
                                    ),
                                    title: Text(
                                      state.listUser[index].name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      state.listUser[index].email,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check,
                                              color: Colors.green),
                                          onPressed: () {
                                            // Xử lý khi người dùng nhấn chấp nhận
                                            BlocProvider.of<FriendRequestBloc>(
                                                    context)
                                                .add(AcceptFriendEvent(
                                                    state.listUser[index].email));
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () {
                                            BlocProvider.of<FriendRequestBloc>(
                                                context)
                                                .add(RejectFriendRequestEvent(
                                                state.listUser[index].email));
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
                        ),
                        if (state.isLoading)
                          const Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: SpinKitWave(
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }else if(state is FriendRequestError){
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        }
        )
    );
  }
}

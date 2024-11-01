import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map/bloc/friend_request_tab/friend_request_bloc.dart';
import 'package:map/bloc/friend_request_tab/friend_request_state.dart';
import 'package:map/common_view/loading.dart';
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
                return loading();
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
                      const SizedBox(height: 16),
                      Expanded(
                        child: Stack(
                          children: [
                            RefreshIndicator(
                              onRefresh: _refreshData,
                              child: _listRequestFriendBuilder(state),
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
                      ),
                    ],
                  ),
                );
              } else if (state is FriendRequestError) {
                return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ));
              }
              return const SizedBox();
            }));
  }

  Widget _listRequestFriendBuilder(FriendRequestLoaded state) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: state.listUser.isEmpty
          ? ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Không có yêu cầu kết bạn',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      )
          : ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.listUser.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key('request_$index'),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                BlocProvider.of<FriendRequestBloc>(context)
                    .add(AcceptFriendEvent(state.listUser[index].email));
              } else if (direction == DismissDirection.endToStart) {
                BlocProvider.of<FriendRequestBloc>(context)
                    .add(RejectFriendRequestEvent(state.listUser[index].email));
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(state.listUser[index].avatarUrl),
                  radius: 30,
                ),
                title: Text(
                  state.listUser[index].name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  state.listUser[index].email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        BlocProvider.of<FriendRequestBloc>(context)
                            .add(AcceptFriendEvent(state.listUser[index].email));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        BlocProvider.of<FriendRequestBloc>(context)
                            .add(RejectFriendRequestEvent(state.listUser[index].email));
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

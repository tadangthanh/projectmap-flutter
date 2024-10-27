import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:map/bloc/friend_tab/friend_bloc.dart';
import 'package:map/bloc/friend_tab/friend_event.dart';
import 'package:map/bloc/friend_tab/friend_state.dart';

class FriendScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FriendScreenState();
  }
}

class _FriendScreenState extends State<FriendScreen> {
  final FriendBloc _friendBloc = FriendBloc();
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
      _friendBloc.add(LoadMoreFriendEvent());
    }
  }

  Future<void> _refreshData() async {
    _friendBloc.add(InitialFriendEvent());
    _scrollController.addListener(loadMoreData);
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _friendBloc,
        child: BlocBuilder<FriendBloc, FriendState>(
            builder: (context, state) {
              if (state is LoadingFriendState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FriendLoaded) {
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
                        'Danh sách bạn bè',
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
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(state.listUser[index].avatarUrl),
                                      ),
                                      title: Text(
                                        state.listUser[index].name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(
                                        state.listUser[index].email,
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      onTap: () {
                                        // Khi nhấn vào, hiển thị cửa sổ nổi từ dưới lên với thông tin chi tiết
                                        showModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (context) {
                                            return Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundImage: NetworkImage(state.listUser[index].avatarUrl),
                                                          radius: 40,
                                                        ),
                                                        const SizedBox(width: 16),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              state.listUser[index].name,
                                                              style: const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              state.listUser[index].email,
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const Divider(),
                                                    const SizedBox(height: 10),
                                                    // Các nút hành động khác
                                                    Wrap(
                                                      spacing: 8.0, // Khoảng cách giữa các nút
                                                      runSpacing: 4.0, // Khoảng cách giữa các hàng (nếu bị tràn)
                                                      alignment: WrapAlignment.center,
                                                      children: [
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            // Xử lý kết bạn
                                                          },
                                                          icon: const Icon(Icons.message, size: 16),
                                                          label: const Text(
                                                            "Nhắn tin",
                                                            style: TextStyle(fontSize: 12),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                                            minimumSize: const Size(90, 40),
                                                          ),
                                                        ),
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            // Xử lý tạo nhóm
                                                          },
                                                          icon: const Icon(Icons.group_add, size: 16),
                                                          label: const Text(
                                                            "Tạo nhóm",
                                                            style: TextStyle(fontSize: 12),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                                            minimumSize: const Size(90, 40),
                                                          ),
                                                        ),
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            // Xử lý hủy kết bạn
                                                          },
                                                          icon: const Icon(Icons.person_add_disabled, size: 16),
                                                          label: const Text(
                                                            "Hủy kết bạn",
                                                            style: TextStyle(fontSize: 12),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                                            minimumSize: const Size(90, 40),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  )
                                  ;
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
              }else if(state is FriendError){
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            }
        )
    );
  }
}

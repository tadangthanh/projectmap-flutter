import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:map/bloc/friend_tab/friend_bloc.dart';
import 'package:map/bloc/friend_tab/friend_event.dart';
import 'package:map/bloc/friend_tab/friend_state.dart';
import 'package:google_fonts/google_fonts.dart';

import 'common_view/loading.dart';

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
        child: BlocBuilder<FriendBloc, FriendState>(builder: (context, state) {
          if (state is LoadingFriendState) {
            return loading();
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
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      state.listUser[index].avatarUrl),
                                  radius: 30,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.grey,size: 16,),
                                title: Text(
                                  state.listUser[index].name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  state.listUser[index].email,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  // Khi nhấn vào, hiển thị cửa sổ nổi từ dưới lên với thông tin chi tiết
                                  _showModal(state, index);
                                },
                              );
                            },
                          ),
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
          } else if (state is FriendError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: GoogleFonts.poppins(
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

  Future _showModal(state, index) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(state.listUser[index].avatarUrl),
                          radius: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.listUser[index].name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                state.listUser[index].email,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                          Icons.send,
                          size: 26,
                          color: Colors.blueAccent,
                        ),
                        hintText:
                            'Gửi tin nhắn cho ${state.listUser[index].name}',
                        hintStyle: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Các nút hành động khác
                    Wrap(
                      spacing: 5.0, // Khoảng cách giữa các nút
                      runSpacing:
                          8.0, // Khoảng cách giữa các hàng (nếu bị tràn)
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        _buttonBuilder("Gọi điện", Icons.phone, () {
                          // Xử lý gọi điện
                        }),
                        _buttonBuilder("Huỷ kết bạn", Icons.person_add_disabled,
                            () {
                          _friendBloc
                              .add(UnFriendEvent(state.listUser[index].email));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buttonBuilder(String label, IconData icon, Function() onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 11),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

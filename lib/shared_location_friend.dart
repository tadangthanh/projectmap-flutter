import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map/bloc/friend_tab/friend_bloc.dart';
import 'package:map/bloc/friend_tab/friend_state.dart';
import 'package:map/common_view/loading.dart';
import 'bloc/friend_tab/friend_event.dart';

class ShareLocationScreen extends StatefulWidget {
  @override
  _ShareLocationScreenState createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  final TextEditingController _noteController = TextEditingController();
  final FriendBloc _friendBloc = FriendBloc();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _friendBloc.add(InitialFriendEvent());
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chia sẻ địa điểm với bạn bè'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) => _friendBloc,
          child:
          BlocBuilder<FriendBloc, FriendState>(builder: (context, state) {
            if (state is LoadingFriendState) {
              return Center(
                child: loading(),
              );
            } else if (state is FriendLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    maxLength: 255,
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chọn bạn bè để chia sẻ:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      state.listUser[index].avatarUrl),
                                  radius: 30,
                                ),
                                trailing: Checkbox(
                                  value: state.friendsSelectedId
                                      .contains(state.listUser[index].id),
                                  onChanged: (bool? value) {
                                    _friendBloc.add(
                                      SelectFriendEvent(state.listUser[index].id!),
                                    );
                                  },
                                ),
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
                                  _friendBloc.add(
                                    SelectFriendEvent(state.listUser[index].id!),
                                  );
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _shareLocation,
                    child: const Text('Chia sẻ vị trí'),
                  ),
                ],
              );
            }
            return Container();
          }),
        ),
      ),
    );
  }

  void _shareLocation() {

  }
}

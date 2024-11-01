import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:map/bloc/user_search/user_search_bloc.dart';
import 'package:map/common_view/loading.dart';
import 'package:map/dto/relation_ship_role.dart';

import 'bloc/user_search/user_search_event.dart';
import 'bloc/user_search/user_search_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserSearchBloc _userSearchBloc = UserSearchBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _userSearchBloc,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Ẩn bàn phím khi nhấn vào chỗ trống
        },
        child: Scaffold(
          body: BlocBuilder<UserSearchBloc, UserSearchState>(
              builder: (context, state) {
            if (state is LoadingUserSearchState) {
              return loading();
            } else if (state is ErrorUserSearchState) {
              return Center(
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  title: const Text(
                    'Thông báo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  content: Text(
                    state.message.split(":").last,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<UserSearchBloc>(context)
                            .add(InitialUserSearchEvent());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is LoadedUserSearchState) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          BlocProvider.of<UserSearchBloc>(context)
                              .add(InitialUserSearchEvent());
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            BlocProvider.of<UserSearchBloc>(context)
                                .add(ExecuteUserSearchEvent(value));
                          }
                        },
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Nhập email bạn bè',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    BlocProvider.of<UserSearchBloc>(context)
                                        .add(InitialUserSearchEvent());
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: state.users.isNotEmpty
                        ? ListView.builder(
                            itemCount: state.users.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 3,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    backgroundImage: NetworkImage(
                                        state.users[index].avatarUrl),
                                    child: null,
                                  ),
                                  title: Text(
                                    state.users[index].name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(state.users[index].email),
                                  trailing: _buildIconAddFriend(
                                      context, state.users[index]),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'Nhập email bạn bè để tìm kiếm',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ),
                ],
              );
            }
            return const SizedBox();
          }),
        ),
      ),
    );
  }
  void showToastMessage(String message) {
    Fluttertoast.showToast(
        msg: message, // Nội dung thông báo
        toastLength: Toast.LENGTH_SHORT, // Độ dài của thông báo (SHORT hoặc LONG)
        gravity: ToastGravity.BOTTOM, // Vị trí hiển thị (BOTTOM, TOP, CENTER)
        backgroundColor: Colors.black, // Màu nền của toast
        textColor: Colors.white, // Màu chữ của toast
        fontSize: 16.0 // Kích thước chữ của toast
    );
  }
  Widget _buildIconAddFriend(context, user) {
    RelationshipRole relationshipRole = user.relationshipRole;
    if (user.friend) {
      return const Icon(Icons.group);
    } else if (relationshipRole == RelationshipRole.TARGET) {
      return TextButton(
        onPressed: () {
          BlocProvider.of<UserSearchBloc>(context)
              .add(UnRequestAddFriendEvent(user.email));
        },
        child: const Text(
          "Đã gửi lời mời",
          style: TextStyle(color: Colors.blueAccent),
        ),
      );
    } else if (relationshipRole == RelationshipRole.AUTHOR) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              BlocProvider.of<UserSearchBloc>(context)
                  .add(AcceptRequestAddFriendEvent(user.email));
            },
            child: const Text(
              "Chấp nhận",
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<UserSearchBloc>(context)
                  .add(RejectRequestAddFriendEvent(user.email));
            },
            child: const Text(
              "Từ chối",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    } else if (relationshipRole == RelationshipRole.NONE) {
      return TextButton(
        onPressed: () {
          BlocProvider.of<UserSearchBloc>(context)
              .add(AddFriendEvent(user.email));
          showToastMessage("Đã gửi lời mời kết bạn");
        },
        child: const Icon(Icons.person_add),
      );
    } else {
      return const SizedBox();
    }
  }
}

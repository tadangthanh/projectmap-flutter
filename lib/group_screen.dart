import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/group/group_list_bloc.dart';
import 'package:map/bloc/group/group_list_state.dart';
import 'package:map/dto/group_response_dto.dart';

import 'bloc/group/group_list_event.dart';
import 'common_view/loading.dart';
import 'dto/user_group_status.dart';
import 'group_create_screen.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  final int selectedIndex;

  const GroupListScreen({this.selectedIndex = 0});

  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen>
    with SingleTickerProviderStateMixin {
  final GroupListBloc _groupListBloc = GroupListBloc();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.selectedIndex);
    _groupListBloc.add(GroupListInitialEvent());
  }

  Future<void> _refreshData() async {
    _groupListBloc.add(GroupListInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _groupListBloc,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Danh sách nhóm'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateGroupScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Đã tham gia'),
              Tab(text: 'Đang chờ tham gia'),
            ],
          ),
        ),
        body: BlocListener<GroupListBloc, GroupListState>(
          listener: (context, state) {
            if (state is GroupListError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showDialog("Lỗi", state.message, () {
                  _groupListBloc.add(GroupListInitialEvent());
                }, null);
              });
            }
          },
          child: BlocBuilder<GroupListBloc, GroupListState>(
            builder: (context, state) {
              if (state is GroupListLoading) {
                return loading();
              } else if (state is GroupListLoaded) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGroupListView(state.groupsJoined,
                        "Bạn chưa tham gia nhóm nào", UserGroupStatus.JOINED),
                    _buildGroupListView(
                        state.groupsPending,
                        "Không có nhóm nào đang chờ duyệt",
                        UserGroupStatus.PENDING),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  void _showDialog(
      String title, String message, Function()? onOk, Function()? onCancel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                if (onOk != null) {
                  onOk();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Ok', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (onCancel != null) {
                  onCancel();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Widget _groupEmptyBuilder(String emptyMessage) {
    return Center(
      child: ListView(
        children: [
          Center(
            heightFactor: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emptyMessage),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateGroupScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Tạo nhóm ngay"),
                      Icon(Icons.add),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupListView(List<GroupResponseDto> groups, String emptyMessage,
      UserGroupStatus status) {
    return RefreshIndicator(
        onRefresh: _refreshData,
        child: groups.isEmpty
            ? _groupEmptyBuilder(emptyMessage)
            : ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        group.name != null && group.name!.trim().isNotEmpty
                            ? group.name![0].toUpperCase()
                            : 'N',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      group.name ?? 'Nhóm của bạn',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: group.description != null
                        ? Text(
                            '${group.description}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: status == UserGroupStatus.JOINED
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.group),
                              const SizedBox(width: 4),
                              Text(
                                "${group.totalMembers}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _groupListBloc.add(
                                      AcceptJoinGroupEvent(groupId: group.id));
                                },
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                tooltip: "Tham gia nhóm",
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  _groupListBloc.add(
                                      RejectJoinGroupEvent(groupId: group.id));
                                },
                                icon: const Icon(Icons.close_outlined,
                                    color: Colors.red),
                                tooltip: "Từ chối tham gia",
                              ),
                            ],
                          ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Wrap(
                            children: <Widget>[
                              _listTitleBuilder("Chi tiết nhóm",
                                  Icons.info_outline, Colors.black, () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GroupDetailScreen(group: group)),
                                );
                              }),
                              group.role != "VIEWER" &&
                                      group.status == UserGroupStatus.JOINED
                                  ? _listTitleBuilder("Chỉnh sửa nhóm",
                                      Icons.edit_outlined, Colors.grey, () {
                                      Navigator.of(context).pop();
                                    })
                                  : Container(),
                              group.role != "VIEWER" &&
                                      group.status == UserGroupStatus.JOINED
                                  ? ListTile(
                                      leading: const Icon(Icons.delete,
                                          color: Colors.red),
                                      title: const Text('Giải tán nhóm',
                                          style: TextStyle(color: Colors.red)),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _showDialog("Xác nhận",
                                            "Bạn có chắc chắn muốn giải tán nhóm ${group.name} không?",
                                            () {
                                          _groupListBloc.add(DisbandGroupEvent(
                                              groupId: group.id));
                                        }, null);
                                      },
                                    )
                                  : Container(),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ));
  }

  Widget _listTitleBuilder(
      String title, IconData icon, Color color, Function onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap as void Function()?,
    );
  }
}

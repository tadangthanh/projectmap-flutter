import 'package:flutter/material.dart';

import 'friends_screen.dart';
import 'friend_request_tab_screen.dart';

class FriendListTabScreen extends StatelessWidget {
  final int selectedIndex;

  const FriendListTabScreen({this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: selectedIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Bạn bè'),
                Tab(text: 'Lời mời kết bạn'),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: TabBarView(
          children: [
            FriendScreen(),
            FriendRequestTab(),
          ],
        ),
      ),
    );
  }
}

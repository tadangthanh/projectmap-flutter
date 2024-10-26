import 'package:flutter/material.dart';

import 'friend_list_tab.dart';
import 'friend_request_tab.dart';

class FriendsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bạn bè', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Danh sách bạn bè'),
                Tab(text: 'Lời mời kết bạn'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            FriendsListTab(),
            FriendRequestsTab(),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Đóng bàn phím khi người dùng click ra ngoài TextField
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          // Buttons at the top (originally in the AppBar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                          : null,
                      hintText: 'Tìm kiếm',
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    // Implement more options here
                  },
                ),
              ],
            ),
          ),
          // Tab bar for messages, online, groups
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Tin nhắn'),
              Tab(text: 'Nhóm của bạn'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMessagesTab(),
                _buildGroupsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildFavoriteContacts(),
        const SizedBox(height: 16),
        _buildRecentChats(),
      ],
    );
  }

  Widget _buildFavoriteContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFriendContact('Sam', 'assets/avatar1.png'),
              _buildFriendContact('Steven', 'assets/avatar2.png'),
              _buildFriendContact('Olivia', 'assets/avatar3.png'),
              _buildFriendContact('John', 'assets/avatar4.png'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendContact(String name, String avatar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(avatar),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRecentChats() {
    return Column(
      children: [
        _buildChatItem('James', 'Hey, how\'s it going?', '5:30 PM', true),
        _buildChatItem('Olivia', 'Can we catch up later?', '4:30 PM', false),
        _buildChatItem('John', 'What about tomorrow?', '3:00 PM', true),
        _buildChatItem('Sophia', 'Let\'s have a meeting', '2:30 PM', false),
        _buildChatItem('Steven', 'Hey, can you send me that file?', '1:30 PM', true),
      ],
    );
  }

  Widget _buildChatItem(String name, String message, String time, bool isNew) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/avatar1.png'), // Replace with actual images for each user
          radius: 25,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time, style: const TextStyle(fontSize: 12)),
            if (isNew)
              const Icon(Icons.new_releases, color: Colors.blue, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Center(child: Text('Groups List'));
  }
}

import 'package:flutter/material.dart';
import 'package:map/search.dart';

import 'friend_list_tab.dart';
import 'map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Danh sách các widget đại diện cho các trang khác nhau
  static final List<Widget> _widgetOptions = <Widget>[
    MapScreen(),
    FriendListTabScreen(),
    SearchScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật trạng thái khi một mục được chọn
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // Chỉ hiển thị widget tại vị trí _selectedIndex
        children: _widgetOptions, // Các trang
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Bản đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Bạn bè',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
        ],
        currentIndex: _selectedIndex, // Mục đã chọn hiện tại
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}





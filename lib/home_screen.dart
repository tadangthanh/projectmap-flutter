import 'package:flutter/material.dart';
import 'package:map/notification_screen.dart';
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
    NotificationScreen(),
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(0, 80, 0, 0),
              items: [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text('Trang chủ'),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text('Hồ sơ cá nhân'),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Text('Cài đặt'),
                ),
              ],
              elevation: 8.0,
            ).then((value) {
              if (value != null) {
                switch (value) {
                  case 0:
                  // Xử lý khi chọn Trang chủ
                    break;
                  case 1:
                  // Xử lý khi chọn Hồ sơ cá nhân
                    break;
                  case 2:
                  // Xử lý khi chọn Cài đặt
                    break;
                }
              }
            });
          },
        ),
        title: Text(
          _getTitle(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.more_horiz_outlined, color: Colors.white),
              onPressed: () {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(1000, 80, 0, 0),
                  items: [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Text('Đánh dấu tất cả là đã đọc'),
                    ),
                  ],
                  elevation: 8.0,
                ).then((value) {
                  if (value != null) {
                    switch (value) {
                      case 0:
                      // Xử lý khi chọn Đánh dấu tất cả là đã đọc
                        break;
                    }
                  }
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1000, 80, 0, 0),
                items: [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Cài đặt chung'),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Thông tin ứng dụng'),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text('Đăng xuất'),
                  ),
                ],
                elevation: 8.0,
              ).then((value) {
                if (value != null) {
                  switch (value) {
                    case 0:
                    // Xử lý khi chọn Cài đặt chung
                      break;
                    case 1:
                    // Xử lý khi chọn Thông tin ứng dụng
                      break;
                    case 2:
                    // Xử lý khi chọn Đăng xuất
                      break;
                  }
                }
              });
            },
          ),
        ],
      ),
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
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
        ],
        currentIndex: _selectedIndex, // Mục đã chọn hiện tại
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Bản đồ';
      case 1:
        return 'Bạn bè';
      case 2:
        return 'Thông báo';
      case 3:
        return 'Tìm kiếm';
      default:
        return 'Ứng dụng';
    }
  }
}
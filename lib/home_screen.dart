import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/home/home_bloc.dart';
import 'package:map/bloc/home/home_state.dart';
import 'package:map/common_view/loading.dart';
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
  // final HomeBloc _homeBloc = HomeBloc();
  int _selectedIndex = 0;

  // Danh sách các widget đại diện cho các trang khác nhau
  static final List<Widget> _widgetOptions = <Widget>[
    const MapScreen(),
    const FriendListTabScreen(),
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
      appBar: _appBarBuilder(),
      body: IndexedStack(
        index: _selectedIndex, // Chỉ hiển thị widget tại vị trí _selectedIndex
        children: _widgetOptions, // Các trang
      ),
      bottomNavigationBar: _buildBottomNavigatorBar(),
    );
  }

  Widget _buildBottomNavigatorBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image(image: AssetImage('assets/icons/icon-map-navigator.png',),width: 26,),
          label: 'Bản đồ',
        ),
        BottomNavigationBarItem(
          icon: Image(image: AssetImage('assets/icons/icon-friend-navigator.png',),width: 26,),
          label: 'Bạn bè',
        ),
        BottomNavigationBarItem(
          icon: Image(image: AssetImage('assets/icons/icon-notification-navigator.png',),width: 26,),
          label: 'Thông báo',
        ),
        BottomNavigationBarItem(
          icon: Image(image: AssetImage('assets/icons/icon-search-navigator.png',),width: 26,),
          label: 'Tìm kiếm',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      showUnselectedLabels: true,
    );
  }

  PreferredSizeWidget? _appBarBuilder() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          showMenu(
            context: context,
            position: const RelativeRect.fromLTRB(0, 80, 0, 0),
            items: [
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Trang chủ'),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Hồ sơ cá nhân'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('Cài đặt'),
              ),
            ],
            elevation: 8.0,
          );
        },
      ),
      title: Text(
        _getTitle(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // centerTitle: true,
      backgroundColor: Colors.blueAccent,
      elevation: 4,
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
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
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

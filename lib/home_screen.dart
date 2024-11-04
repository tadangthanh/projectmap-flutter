import 'package:flutter/material.dart';
import 'package:map/generated/assets.dart';
import 'package:map/group_screen.dart';
import 'package:map/notification_screen.dart';
import 'package:map/search.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

import 'friend_list_tab.dart';
import 'map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget  {
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

class HomePage extends StatefulWidget  {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  // final HomeBloc _homeBloc = HomeBloc();
  int _selectedIndex = 0;
  // TabController _tabController;
 late MotionTabBarController _motionTabBarController;
  // Danh sách các widget đại diện cho các trang khác nhau
  static final List<Widget> _widgetOptions = <Widget>[
    const MapScreen(),
    const FriendListTabScreen(),
    NotificationScreen(),
    SearchScreen(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 1,
      length: 4,
      vsync: this,
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _motionTabBarController.dispose();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật trạng thái khi một mục được chọn
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarBuilder(context),
      body: IndexedStack(
        index: _selectedIndex, // Chỉ hiển thị widget tại vị trí _selectedIndex
        children: _widgetOptions, // Các trang
      ),
      bottomNavigationBar: _buildBottomNavigatorBar(),
      drawer: _drawerBuilder(context),
    );
  }
Widget _drawerBuilder(context){
    return Drawer(
      child: Column(
        children: <Widget>[
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              'User Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('user@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'U',
                style: TextStyle(fontSize: 40.0, color: Colors.blueAccent),
              ),
            ),
          ),
          ListTile(
            leading: const Image(
              image: AssetImage(Assets.iconsIconGroup),
              width: 26,
            ),
            title: const Text('Nhóm'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupListScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.blueAccent),
            title: const Text('Cài đặt'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Đăng xuất',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
}



  Widget _buildBottomNavigatorBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage(
              'assets/icons/icon-map-navigator.png',
            ),
            width: 26,
          ),
          label: 'Bản đồ',
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage(
              'assets/icons/icon-friend-navigator.png',
            ),
            width: 26,
          ),
          label: 'Bạn bè',
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage(
              'assets/icons/icon-notification-navigator.png',
            ),
            width: 26,
          ),
          label: 'Thông báo',
        ),
        BottomNavigationBarItem(
          icon: Image(
            image: AssetImage(
              'assets/icons/icon-search-navigator.png',
            ),
            width: 26,
          ),
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

  PreferredSizeWidget? _appBarBuilder(context) {
    return AppBar(
      leading: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
      }),
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

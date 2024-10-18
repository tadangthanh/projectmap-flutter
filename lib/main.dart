import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user; // Biến lưu thông tin người dùng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _user == null // Kiểm tra xem người dùng có đăng nhập không
            ? TextButton(
          onPressed: () async {
            _user = await _googleSignIn.signIn();
            setState(() {}); // Cập nhật lại giao diện
          },
          child: const Text("Login"),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${_user?.displayName}'), // Hiển thị tên người dùng
            const SizedBox(height: 20), // Khoảng cách giữa các widget
            TextButton(
              onPressed: () async {
                await _googleSignIn.signOut(); // Đăng xuất người dùng
                setState(() {
                  _user = null; // Cập nhật lại trạng thái
                });
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

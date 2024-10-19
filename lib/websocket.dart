import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

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
      home: const Chat(),
    );
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late StompClient client;

  @override
  void initState() {
    super.initState();
    client = StompClient(
        config: StompConfig(
          url: "ws://192.168.1.242:8080?token=kkk",
          onConnect: onConnect,
          onWebSocketError: (dynamic error) => print('WebSocket error: $error'),
        ));
    client.activate(); // Kích hoạt client
  }

  void onConnect(StompFrame frame) {
    print('Connected: ${frame.headers}');
    client.subscribe(
        destination: '/user/234234/location',
        callback: (StompFrame frame) {
          print('Received message: ${frame.body}');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              client.send(destination: '/app/share-location', body: jsonEncode({"lat": 10.762622, "lng": 106.660172,"id": 234234}));
            },
            child: Text("send message")),
      ),
    );
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TCP Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final String serverIp = "192.168.0.138"; // ⚠️ 替換成你的電腦 IP
  final int serverPort = 65432;

  Socket? _socket;
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _connect();
  }

  String _timestamp() => DateFormat('HH:mm').format(DateTime.now());

  void _connect() async {
    try {
      _socket = await Socket.connect(serverIp, serverPort).timeout(Duration(seconds: 5));
      _addMessage("Connected to $serverIp:$serverPort");

      // Desktop/Windows 需要 map Uint8List -> utf8.decode
      _socket!.map((event) => utf8.decode(event)).listen((data) {
        _addMessage("Server: $data");
      }, onError: (error) {
        _addMessage("Error: $error");
      }, onDone: () {
        _addMessage("Disconnected from server");
      });
    } catch (e) {
      _addMessage("Connection failed: $e");
    }
  }

  void _sendMessage() {
    if (_socket != null && _controller.text.isNotEmpty) {
      String msg = _controller.text;
      _socket!.write(msg);
      _addMessage("Me: $msg");
      _controller.clear();
    }
  }

  void _addMessage(String msg) {
    setState(() {
      _messages.add("${_timestamp()} $msg");
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _socket?.destroy();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter ↔ TCP Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_messages[index]),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter message...",
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}

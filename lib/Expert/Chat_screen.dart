import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [
    // Danh sách các tin nhắn ví dụ
    Message(
        isMe: true,
        text: 'Xin chào, bạn có thể giúp tôi với vấn đề này không?',
        time: '10:00 AM'),
    Message(
        isMe: false,
        text:
        'Chào bạn, mình sẵn lòng giúp bạn. Bạn có thể mô tả vấn đề của mình rõ hơn không?',
        time: '10:05 AM'),
  ];
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm tin nhắn',
            hintStyle: TextStyle(
              color: Colors.black12,
            ),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            filled: true,
            fillColor: Colors.white12,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Card(

            );
          },
        ),
      ),
    );
  }
}

class Message {
  final bool isMe;
  final String text;
  final String time;

  Message({required this.isMe, required this.text, required this.time});
}

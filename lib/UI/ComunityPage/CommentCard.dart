import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/UI/ComunityPage/PostController.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Thêm hiệu ứng đổ bóng nhẹ cho card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Góc bo tròn cho card
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Thêm padding cho card
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25, // Đặt kích thước cho avatar
              backgroundColor: Colors.blue, // Màu nền cho avatar
              child: Text(
                comment.user[0], // Lấy chữ cái đầu tiên của tên người dùng
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(width: 10), // Khoảng cách giữa avatar và nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.user,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(comment.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    comment.comment,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up, color: Colors.blue),
                        onPressed: () {
                          // Logic cho like button
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.comment, color: Colors.blue),
                        onPressed: () {
                          // Logic cho reply button
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

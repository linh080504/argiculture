import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather/UI/ComunityPage/PostController.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weather/UI/ComunityPage/CommentList.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Obx(
                  () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hàng với ảnh đại diện và tên người dùng
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150', // Placeholder cho ảnh đại diện
                        ),
                        radius: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        Get.find<PostController>().posts
                            .firstWhere((p) => p.id == post.id)
                            .user,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  // Thời gian đăng bài
                  Text(
                    '${Get.find<PostController>().posts.firstWhere((p) => p.id == post.id).timestamp.toLocal()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Tiêu đề bài viết
                  Text(
                    Get.find<PostController>().posts
                        .firstWhere((p) => p.id == post.id)
                        .title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Hiển thị hình ảnh nếu có
                  if (post.images.isNotEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                post.images[index],
                                fit: BoxFit.cover,
                                width: 200,
                                height: 200,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                  // Đường kẻ ngang
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  // Các nút hành động
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.favorite, color: Colors.redAccent),
                        label: Text(
                          'Thích',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 0,
                          side: BorderSide(color: Colors.redAccent),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CommentList(postId: post.id),
                            ),
                          );
                        },
                        icon: Icon(Icons.comment, color: Colors.blueAccent),
                        label: Text(
                          'Bình luận',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 0,
                          side: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Share.share('Bạn muốn chia sẻ đến ai?');
                        },
                        icon: Icon(Icons.share, color: Colors.greenAccent),
                        label: Text(
                          'Chia sẻ',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 0,
                          side: BorderSide(color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        color: Colors.lightGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' ${Get.find<PostController>().posts.firstWhere((p) => p.id == post.id).user}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '  ${Get.find<PostController>().posts.firstWhere((p) => p.id == post.id).timestamp.toLocal()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white38,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      '  ${Get.find<PostController>().posts.firstWhere((p) => p.id == post.id).title}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Like',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                              side: BorderSide(
                                  color: Colors.white, // Màu viền
                                  width: 1),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 5,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommentList(postId: post.id),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.comment,
                            color: Colors.white,
                          ),
                          label: Text(
                            'CMT',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                              side: BorderSide(color: Colors.white, width: 1),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 5,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Share.share('Bạn muốn chia sẻ đến ai?'
                            );
                          },
                          icon: Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Share',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                              side: BorderSide(
                                  color: Colors.white, // Màu viền
                                  width: 1),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

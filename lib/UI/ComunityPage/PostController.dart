import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostController extends GetxController {
  var title = ''.obs;
  var selectedImages = <XFile>[].obs;
  var posts = <Post>[].obs;
  final comments = <Comment>[].obs;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> fetchPosts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      posts.value = snapshot.docs.map((doc) {
        var post = Post(
          id: doc.id,
          title: doc['title'],
          user: doc['user'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          images: List<String>.from(doc['images']),
          comments: [],
        );

        FirebaseFirestore.instance
            .collection('posts')
            .doc(doc.id)
            .collection('comments')
            .orderBy('timestamp')
            .get()
            .then((commentSnapshot) {
          post.comments = commentSnapshot.docs.map((commentDoc) {
            return Comment.fromJson(commentDoc.data());
          }).toList();
        });

        return post;
      }).toList();
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  Future<void> addPost(String userName, {List<XFile>? images}) async {
    try {
      // Tạo một ID duy nhất cho post mới
      String postId = FirebaseFirestore.instance.collection('posts').doc().id;
      List<String> imageUrls = [];

      // Kiểm tra nếu có hình ảnh trong `selectedImages`
      for (XFile image in selectedImages) {
        try {
          File imageFile = File(image.path);
          String fileName = '$postId-${image.name}';

          // Tạo một tham chiếu đến vị trí lưu trữ ảnh
          final ref = _storage.ref().child('posts/$fileName');

          // Dùng `putFile` để tải ảnh lên Firebase Storage
          UploadTask uploadTask = ref.putFile(imageFile);

          // Chờ upload hoàn tất
          TaskSnapshot snapshot = await uploadTask;
          if (snapshot.state == TaskState.success) {
            // Lấy URL của ảnh
            String downloadUrl = await snapshot.ref.getDownloadURL();
            imageUrls.add(downloadUrl);
            print("Image uploaded: $downloadUrl");
          } else {
            print("Failed to upload image: ${snapshot.state}");
          }
        } catch (uploadError) {
          print("Error uploading image: $uploadError");
        }
      }

      // Lưu dữ liệu bài viết với URLs của ảnh vào Firestore
      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'user': userName,
        'title': title.value,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
        'images': imageUrls, // Lưu URLs của ảnh
      });

      // Reset sau khi thêm post
      title.value = '';
      selectedImages.clear();
      print("Post added successfully!");

      fetchPosts(); // Reload danh sách posts
    } catch (e) {
      print("Error adding post: $e");
    }
  }


  Future<void> fetchComments(String postId) async {
    try {
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      List<Comment> fetchedComments = commentSnapshot.docs.map((doc) {
        return Comment.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      Get.find<PostController>().comments.value = fetchedComments;
      Get.find<PostController>().update();
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  Future<void> addComment(String postId, String userName, String commentText) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'user': userName,
        'comment': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Comment added successfully!");

      fetchPosts();
    } catch (e) {
      print("Error adding comment: $e");
    }
  }
}

class Post {
  final String id;
  final String title;
  final String user;
  final DateTime timestamp;
  final List<String> images;
  List<Comment> comments = [];

  Post({
    required this.id,
    required this.title,
    required this.user,
    required this.timestamp,
    required this.images,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      user: json['user'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      images: List<String>.from(json['images']),
      comments: List<Comment>.from(
        json['comments']?.map((x) => Comment.fromJson(x)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['title'] = this.title;
    data['user'] = this.user;
    data['timestamp'] = Timestamp.fromDate(timestamp);
    data['images'] = this.images;
    data['comments'] = this.comments.map((comment) => comment.toJson()).toList();
    return data;
  }
}

class Comment {
  final String user;
  final String comment;
  final DateTime timestamp;

  Comment({
    required this.user,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['user'] as String,
      comment: json['comment'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = this.user;
    data['comment'] = this.comment;
    data['timestamp'] = Timestamp.fromDate(timestamp);
    return data;
  }
}
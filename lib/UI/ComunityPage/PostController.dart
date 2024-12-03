import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;


class PostController extends GetxController {
  var title = ''.obs;
  var selectedImages = <XFile>[].obs;
  var posts = <Post>[].obs;
  var comments = <Comment>[].obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> fetchPosts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      posts.value = snapshot.docs.map((doc) {
        return Post(
          id: doc.id,
          title: doc['title'],
          user: doc['user'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          images: List<String>.from(doc['images']),
          comments: [],
        );
      }).toList();
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  Future<void> addPost({
    required String title,
    required List<XFile> images,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("User not logged in!");
        return;
      }
      String userId = currentUser.email ?? currentUser.uid;  // Lấy userId (email hoặc UID) của người dùng hiện tại
      List<String> imageUrls = [];
      for (XFile image in images) {
        try {
          File imageFile = File(image.path);
          String fileName = '${DateTime.now().millisecondsSinceEpoch}-${image.name}';
          final ref = FirebaseStorage.instance.ref().child('posts/$fileName');
          UploadTask uploadTask = ref.putFile(imageFile);

          TaskSnapshot snapshot = await uploadTask;
          if (snapshot.state == TaskState.success) {
            String downloadUrl = await snapshot.ref.getDownloadURL();
            imageUrls.add(downloadUrl);
          }
        } catch (e) {
          print("Error uploading image: $e");
        }
      }
      String postId = FirebaseFirestore.instance.collection('posts').doc().id;

      Map<String, dynamic> postData = {
        'title': title,
        'timestamp': FieldValue.serverTimestamp(),
        'images': imageUrls,
        'user': userId,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('posts')
          .doc(postId)
          .set(postData);

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .set(postData);

      print("Post added successfully!");
    } catch (e) {
      throw Exception("Error adding post: $e");
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
      Get.find<PostController>().update();  // Cập nhật UI

    } catch (e) {
      print("Error fetching comments: $e");
    }
  }
  Future<void> addComment(String postId, String commentText, XFile? imageFile) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập.');
      }

      String userId = currentUser.email ?? 'unknown_user@email.com'; // Dùng email làm userId
      String userName = currentUser.displayName ?? 'Người dùng'; // Tên người comment
      String profilePicture = currentUser.photoURL ?? 'https://via.placeholder.com/150'; // Ảnh đại diện người comment

      String commentId = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc()
          .id;

      Map<String, dynamic> commentData = {
        'commentId': commentId,
        'text': commentText,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'userName': userName,
        'profilePicture': profilePicture
      };

      if (imageFile != null) {
        String imageUrl = await uploadImage(imageFile);
        commentData['imageUrl'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(commentData);

      print('Thêm bình luận thành công!');
    } catch (e) {
      print('Lỗi khi thêm bình luận: $e');
      throw e;
    }
  }

  Future<String> uploadImage(XFile imageFile) async {
    try {
      String fileName = path.basename(imageFile.path);
      Reference storageRef = FirebaseStorage.instance.ref().child('comments_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
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
  final String userId;
  final String comment;
  final DateTime timestamp;
  final String profilePicture;

  Comment({
    required this.userId,
    required this.comment,
    required this.timestamp,
    required this.profilePicture,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId'] as String,
      comment: json['text'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      profilePicture: json['profilePicture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['timestamp'] = Timestamp.fromDate(timestamp);
    data['profilePicture'] = this.profilePicture;
    return data;
  }
}

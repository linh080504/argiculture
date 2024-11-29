import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilesController extends GetxController {
  var expertList = <ExpertData>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách hồ sơ chuyên gia
  Future<void> fetchExpertProfiles() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      // Lấy danh sách tất cả hồ sơ của người dùng
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.email)  // Dùng email làm ID người dùng
          .collection('profiles')
          .get();

      // Xóa danh sách hiện tại và thêm các hồ sơ mới vào expertList
      expertList.clear();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        ExpertData profile = ExpertData(
          id: doc.id,
          userId: user.uid,
          fullName: data['fullname'] ?? '',
          bio: data['bio'] ?? '',
          degree: data['degree'] ?? '',
          profilePictureUrl: data['avt'] ?? '',
        );

        // Kiểm tra nếu đã tồn tại hồ sơ với profileId trùng lặp
        bool exists = expertList.any((p) => p.id == profile.id);
        if (!exists) {
          expertList.add(profile);
        }
      }
    } catch (e) {
      print('Error fetching expert profiles: $e');
    }
  }

  // Lưu hoặc cập nhật hồ sơ của người dùng
  Future<void> saveOrUpdateProfile(String fullName, String bio, String degree, XFile? profilePic) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String userId = user.uid;
      String profileId = user.email ?? ''; // Dùng email làm profileId
      String? profilePicUrl;

      // Tải ảnh lên nếu có ảnh mới
      if (profilePic != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/$userId/$profileId.jpg');
        UploadTask uploadTask = storageReference.putFile(File(profilePic.path));
        TaskSnapshot snapshot = await uploadTask;
        profilePicUrl = await snapshot.ref.getDownloadURL();
      }

      // Tạo hoặc cập nhật hồ sơ trong Firestore
      await _firestore
          .collection('users')
          .doc(user.email)  // Dùng email làm document ID
          .collection('profiles')
          .doc(profileId)  // Dùng email làm profile ID
          .set({
        'fullname': fullName,
        'bio': bio,
        'degree': degree,
        'avt': profilePicUrl ?? '',  // URL ảnh nếu có
      }, SetOptions(merge: true));

      // Cập nhật lại danh sách hồ sơ chuyên gia
      fetchExpertProfiles();
    } catch (e) {
      print('Error saving/updating profile: $e');
    }
  }

  // Xóa hồ sơ của người dùng
  Future<void> deleteProfile(String profileId) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      // Xóa hồ sơ trong Firestore
      await _firestore
          .collection('users')
          .doc(user.email)  // Dùng email làm document ID
          .collection('profiles')
          .doc(profileId)  // Dùng profileId để xóa
          .delete();

      // Cập nhật lại danh sách hồ sơ chuyên gia
      fetchExpertProfiles();
    } catch (e) {
      print('Error deleting profile: $e');
    }
  }
}

// Model cho dữ liệu chuyên gia
class ExpertData {
  final String id;
  final String userId;
  final String fullName;
  final String bio;
  final String degree;
  final String profilePictureUrl;

  ExpertData({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.bio,
    required this.degree,
    required this.profilePictureUrl,
  });
}

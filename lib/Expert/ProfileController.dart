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

  Future<void> fetchExpertProfiles() async {
    try {
      QuerySnapshot userDocs = await _firestore.collection('users').get();

      expertList.clear();

      for (var userDoc in userDocs.docs) {
        String userEmail = userDoc.id;

        DocumentSnapshot profileDoc = await userDoc.reference
            .collection('profiles')
            .doc(userEmail)
            .get();

        if (profileDoc.exists) {
          Map<String, dynamic> data = profileDoc.data() as Map<String, dynamic>;

          ExpertData profile = ExpertData(
            id: userEmail, // Email làm ID cho profile
            userId: userDoc.id, // ID của user
            fullName: data['fullname'] ?? '',
            bio: data['bio'] ?? '',
            degree: data['degree'] ?? '',
            profilePictureUrl: data['avt'] ?? '',
            experience: data['experience'] ?? '',
            supportGroup: data['supportGroup'] ?? '',
          );

          expertList.add(profile);
        }
      }
    } catch (e) {
      print('Error fetching expert profiles: $e');
    }
  }

  Future<void> saveOrUpdateProfile(
      String fullName,
      String bio,
      String degree,
      String experience,
      String supportGroup,
      XFile? profilePic,
      ) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String userId = user.uid;
      String profileId = user.email ?? '';
      String? profilePicUrl;


      if (profilePic != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/$userId/$profileId.jpg');
        UploadTask uploadTask = storageReference.putFile(File(profilePic.path));
        TaskSnapshot snapshot = await uploadTask;
        profilePicUrl = await snapshot.ref.getDownloadURL();
      }

      DocumentReference profileRef = _firestore
          .collection('users')
          .doc(user.email)
          .collection('profiles')
          .doc(profileId);

      bool profileExists = (await profileRef.get()).exists;
      if (profileExists) {
        await profileRef.delete();
      }

      await profileRef.set({
        'fullname': fullName,
        'bio': bio,
        'degree': degree,
        'experience': experience,
        'supportGroup': supportGroup,
        'avt': profilePicUrl ?? '',
      });


      fetchExpertProfiles();
    } catch (e) {
      print('Error saving/updating profile: $e');
    }
  }


  Future<void> deleteProfile(String profileId) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.email)
          .collection('profiles')
          .doc(profileId)
          .delete();

      fetchExpertProfiles();
    } catch (e) {
      print('Error deleting profile: $e');
    }
  }
}


class ExpertData {
  final String id;
  final String userId;
  final String fullName;
  final String bio;
  final String degree;
  final String profilePictureUrl;
  final String experience;
  final String supportGroup;

  ExpertData({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.bio,
    required this.degree,
    required this.profilePictureUrl,
    required this.experience,
    required this.supportGroup,
  });
}

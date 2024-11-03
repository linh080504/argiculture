import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addUserToFirestore(String email, String fullname, String password) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  try {
    // Tạo người dùng mới với email và mật khẩu
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Lưu thông tin người dùng vào Firestore
    await users.doc(userCredential.user!.uid).set({
      'email': email,
      'fullname': fullname,
      // Không lưu mật khẩu, vì nó không an toàn
    });

    print('User added to Firestore: $email');
  } catch (e) {
    print('Error adding user to Firestore: $e');
  }
}

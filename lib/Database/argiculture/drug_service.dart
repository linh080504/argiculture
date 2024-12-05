import 'dart:typed_data'; // Để sử dụng Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DrugService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<dynamic>> getAllDrugs() async {
    final querySnapshot = await _firestore.collection('drugs').get();
    return querySnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
  Future<List<Map<String, dynamic>>> fetchDrugs() async {
    QuerySnapshot snapshot = await _firestore.collection('drugs').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<dynamic> getDrugById(String id) async {
    final doc = await _firestore.collection('drugs').doc(id).get();
    return {'id': doc.id, ...doc.data()!};
  }

  Future<void> addDrug(Map<String, dynamic> drugData) async {
    await _firestore.collection('drugs').add(drugData);
  }

  Future<void> updateDrug(String id, Map<String, dynamic> drugData) async {
    await _firestore.collection('drugs').doc(id).update(drugData);
  }

  Future<void> deleteDrug(String id) async {
    await _firestore.collection('drugs').doc(id).delete();
  }

  Future<String> uploadImage(Uint8List data, String fileName) async {
    try {
      // Tự động xác định contentType dựa trên phần mở rộng của file
      String fileExtension = fileName.split('.').last.toLowerCase();
      String contentType = 'image/$fileExtension';

      final ref = _storage.ref().child('images/$fileName');

      UploadTask uploadTask = ref.putData(data, SettableMetadata(contentType: contentType));

      // Theo dõi tiến trình upload (tùy chọn)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Đang tải lên: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Đợi cho đến khi upload hoàn tất và lấy URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // Trả về URL của ảnh đã tải lên
    } catch (e) {
      print("Lỗi upload ảnh: $e");
      return '';
    }
  }
  Future<String> getImageUrl(String path) async {
    try {
      // Lấy tham chiếu tới tệp tin trong Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(path);

      // Lấy URL chính thức từ Firebase Storage
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;  // Trả về URL chính thức
    } catch (e) {
      print('Error fetching image URL: $e');
      return '';  // Trả về chuỗi rỗng nếu có lỗi
    }
  }



}

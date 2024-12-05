import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:weather/Amin/plants/crop.dart';
import 'dart:io';

class CropService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add Crop
  Future<void> addCrop(Crop crop, {
    File? imageFile, // ảnh đại diện
    List<File?>? introductionImages, // ảnh cho phần Giới thiệu
    List<File?>? environmentImages, // ảnh cho phần Môi trường
    List<File?>? propagationImages, // ảnh cho phần Nhân giống
    List<File?>? plantingImages, // ảnh cho phần Trồng cây
  }) async {
    try {
      String imageUrl = '';

      // Upload ảnh đại diện nếu có
      if (imageFile != null && imageFile.existsSync()) {
        Reference ref = _storage.ref().child('crops/${crop.id}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      // Cập nhật URL ảnh vào crop
      crop = crop.copyWith(imageUrl: imageUrl);

      // Tạo một bản đồ lưu URL ảnh cho từng phần
      Map<String, List<String>> stepImages = {};

      // Upload ảnh cho từng bước và lưu URL ảnh
      if (introductionImages != null) {
        stepImages['introduction'] = await _uploadStepImages(crop.id, 'introduction', introductionImages);
      }
      if (environmentImages != null) {
        stepImages['environment'] = await _uploadStepImages(crop.id, 'environment', environmentImages);
      }
      if (propagationImages != null) {
        stepImages['propagation'] = await _uploadStepImages(crop.id, 'propagation', propagationImages);
      }
      if (plantingImages != null) {
        stepImages['planting'] = await _uploadStepImages(crop.id, 'planting', plantingImages);
      }

      // Lưu crop vào Firestore, bao gồm cả ảnh cho từng bước
      await _firestore.collection('crops').doc(crop.id).set({
        ...crop.toJson(),
        'stepImages': stepImages, // Lưu ảnh cho từng bước
      });
    } catch (e) {
      throw Exception("Failed to add crop: $e");
    }
  }


  // Update Crop
  Future<void> updateCrop(Crop crop, {
    File? imageFile, // ảnh đại diện
    List<File?>? introductionImages, // ảnh cho phần Giới thiệu
    List<File?>? environmentImages, // ảnh cho phần Môi trường
    List<File?>? propagationImages, // ảnh cho phần Nhân giống
    List<File?>? plantingImages, // ảnh cho phần Trồng cây
  }) async {
    try {
      String imageUrl = crop.imageUrl;

      // Thay thế ảnh đại diện nếu có ảnh mới
      if (imageFile != null) {
        Reference ref = _storage.ref().child('crops/${crop.id}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      // Cập nhật crop với ảnh đại diện mới
      crop = crop.copyWith(imageUrl: imageUrl);

      // Tạo một bản đồ lưu URL ảnh cho từng phần
      Map<String, List<String>> stepImages = {};

      // Upload ảnh cho từng bước và lưu URL ảnh
      if (introductionImages != null) {
        stepImages['introduction'] = await _uploadStepImages(crop.id, 'introduction', introductionImages);
      }
      if (environmentImages != null) {
        stepImages['environment'] = await _uploadStepImages(crop.id, 'environment', environmentImages);
      }
      if (propagationImages != null) {
        stepImages['propagation'] = await _uploadStepImages(crop.id, 'propagation', propagationImages);
      }
      if (plantingImages != null) {
        stepImages['planting'] = await _uploadStepImages(crop.id, 'planting', plantingImages);
      }

      // Cập nhật crop vào Firestore
      await _firestore.collection('crops').doc(crop.id).update({
        ...crop.toJson(),
        'stepImages': stepImages, // Cập nhật ảnh cho từng bước
      });
    } catch (e) {
      throw Exception("Failed to update crop: $e");
    }
  }

  // Delete Crop
  Future<void> deleteCrop(String cropId) async {
    try {
      // Xóa ảnh trong Firebase Storage
      await _storage.ref().child('crops/$cropId.jpg').delete();

      // Xóa document trong Firestore
      await _firestore.collection('crops').doc(cropId).delete();
    } catch (e) {
      throw Exception("Failed to delete crop: $e");
    }
  }

  // Fetch Crops
  Future<List<Crop>> fetchCrops() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance.collection('crops').get();

      querySnapshot.docs.forEach((doc) {
        print("Document data: ${doc.data()}");  // In dữ liệu của mỗi tài liệu để kiểm tra
      });
      // Kiểm tra nếu querySnapshot.docs bị null hoặc rỗng
      if (querySnapshot.docs == null || querySnapshot.docs.isEmpty) {
        return [];  // Trả về danh sách rỗng nếu không có tài liệu
      }

      // Nếu có dữ liệu, ánh xạ thành danh sách Crop
      List<Crop> crops = querySnapshot.docs.map((doc) {
        return Crop.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return crops;
    } catch (e) {
      print("Failed to fetch crops: $e");
      throw Exception("Failed to fetch crops: $e");
    }
  }


  // Upload ảnh cho từng bước
  Future<List<String>> _uploadStepImages(String cropId, String section, List<File?> images) async {
    List<String> imageUrls = [];
    for (var i = 0; i < images.length; i++) {
      if (images[i] != null && images[i]!.existsSync()) {
        Reference ref = _storage.ref().child('crops/$cropId/$section/${section}_step_$i.jpg');
        await ref.putFile(images[i]!);
        String imageUrl = await ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } else {
        throw Exception("Invalid image file: ${images[i]?.path}");
      }
    }
    return imageUrls;
  }

}

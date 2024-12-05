import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:weather/Amin/plants/crop.dart';
import 'package:weather/Database/argiculture/crop_service.dart';

class CropController extends ChangeNotifier {
  final CropService _cropService = CropService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Thêm cây trồng vào Firestore
  // Thêm cây trồng vào Firestore
  Future<void> addCrop(Crop crop, Map<String, List<String>> stepImages) async {
    try {
      // Lưu cây trồng vào Firestore (không lưu imageFile trực tiếp)
      DocumentReference cropRef = await _firestore.collection('crops').add({
        'name': crop.name,
        'definition': crop.definition,
        'imageUrl': crop.imageUrl,
        'introduction': crop.introduction,
        'environment': crop.environment,
        'propagation': crop.propagation,
        'planting': crop.planting,
        'introductionSteps': crop.introductionSteps,
        'environmentSteps': crop.environmentSteps,
        'propagationSteps': crop.propagationSteps,
        'plantingSteps': crop.plantingSteps,
      });

      // Lưu URL ảnh cho từng bước vào Firestore (sub-collections)
      for (var section in stepImages.keys) {
        for (var url in stepImages[section]!) {
          // Lưu URL ảnh vào sub-collection của từng bước
          await cropRef.collection(section).add({
            'imageUrl': url,
          });
        }
      }
    } catch (e) {
      print('Error adding crop: $e');
      throw e;
    }
  }

  // Tải ảnh lên Firebase Storage và lấy URL
  Future<String> uploadImage(File image, String section) async {
    try {
      // Tạo đường dẫn tải lên ảnh
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('crops/$section/$fileName');

      // Tải ảnh lên Firebase Storage
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // Lấy URL của ảnh sau khi tải lên thành công
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;  // Trả về URL của ảnh
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }


  List<Crop> crops = [];
  bool isLoading = false;
  String errorMessage = '';  // Lưu trữ thông báo lỗi nếu có

  // Fetch crops
  Future<void> loadCrops() async {
    isLoading = true;
    errorMessage = '';  // Reset thông báo lỗi khi bắt đầu tải
    notifyListeners();

    try {
      crops = await _cropService.fetchCrops();

      // Kiểm tra nếu crops là null hoặc rỗng
      if (crops == null || crops.isEmpty) {
        errorMessage = "No crops found";  // Thông báo nếu không có cây trồng
      }

      // Nếu có cây trồng, lấy các bước từ sub-collection
      for (var crop in crops) {
        var stepsSnapshot = await FirebaseFirestore.instance
            .collection('crops')
            .doc(crop.id)
            .collection('steps')
            .get();

        // Lưu tất cả các bước vào cây trồng
        crop.introductionSteps = [];
        crop.environmentSteps = [];
        crop.propagationSteps = [];
        crop.plantingSteps = [];

        stepsSnapshot.docs.forEach((doc) {
          String section = doc['section'];
          Map<String, dynamic> step = {
            'description': doc['description'],
            'image': doc['image'], // URL của ảnh
          };

          // Phân loại theo từng phần
          switch (section) {
            case 'introduction':
              crop.introductionSteps.add(step);
              break;
            case 'environment':
              crop.environmentSteps.add(step);
              break;
            case 'propagation':
              crop.propagationSteps.add(step);
              break;
            case 'planting':
              crop.plantingSteps.add(step);
              break;
          }
        });
      }

    } catch (e) {
      errorMessage = "Error loading crops: $e";  // Lưu thông báo lỗi
      print("Error loading crops: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }




  // Update crop
  Future<void> updateCrop(Crop crop, File? imageFile) async {
    try {
      await _cropService.updateCrop(crop);  // Chỉ truyền crop vào
      await loadCrops();  // Reload crops after update
    } catch (e) {
      errorMessage = "Failed to update crop: $e";
      notifyListeners();
    }
  }


  // Delete crop
  Future<void> deleteCrop(String cropId) async {
    try {
      await _cropService.deleteCrop(cropId);
      await loadCrops();  // Reload crops after deletion
    } catch (e) {
      errorMessage = "Failed to delete crop: $e";  // Lưu thông báo lỗi
      notifyListeners();
    }
  }
}

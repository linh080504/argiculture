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

  Future<Crop> getCropById(String cropId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('crops').doc(cropId).get();
      if (doc.exists) {
        return Crop.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Cây trồng không tồn tại');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy cây trồng: $e');
    }
  }
  // Thêm cây trồng vào Firestore
  Future<void> addCrop(Crop crop, Map<String, List<String>> stepImages) async {
    try {
      // Lưu cây trồng vào Firestore với ID theo timestamp
      String timestampId = crop.id;  // ID đã được tạo từ bên ngoài

      await _firestore.collection('crops').doc(timestampId).set({
        'id' : timestampId,
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

      // Cập nhật lại crop.id sau khi thêm thành công
      crop.id = timestampId;

      // Lưu URL ảnh cho từng bước vào Firestore (sub-collections)
      for (var section in stepImages.keys) {
        for (var url in stepImages[section]!) {
          // Lưu URL ảnh vào sub-collection của từng bước
          await _firestore.collection('crops').doc(timestampId).collection(section).add({
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

// Cập nhật cây trồng trong Firestore
  Future<void> updateCrop(Crop crop) async {
    try {
      await _firestore.collection('crops').doc(crop.id).update(crop.toJson());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật cây trồng: $e');
    }
  }

  Future<Crop> getCropFromFirestore(String cropId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('crops').doc(cropId).get();

      if (doc.exists) {
        // Chuyển đổi từ JSON sang đối tượng Crop
        return Crop.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Crop not found');
      }
    } catch (e) {
      throw Exception('Error fetching crop: $e');
    }
  }
  Future<void> deleteCrop(String cropId) async {
    try {
      // Xóa tất cả các sub-collections liên quan đến cây trồng
      for (var section in ['introduction', 'environment', 'propagation', 'planting']) {
        var sectionCollection = _firestore.collection('crops').doc(cropId).collection(section);
        var snapshot = await sectionCollection.get();
        for (var doc in snapshot.docs) {
          // Nếu cần, xóa ảnh trong Firebase Storage trước (nếu ảnh lưu trong Firestore có URL)
          if (doc['imageUrl'] != null) {
            try {
              await _storage.refFromURL(doc['imageUrl']).delete();
            } catch (e) {
              print("Error deleting image from storage: $e");
            }
          }
          await doc.reference.delete();
        }
      }

      // Xóa tài liệu chính của cây trồng
      await _firestore.collection('crops').doc(cropId).delete();

      // Sau khi xóa, tải lại danh sách cây trồng
      await loadCrops();

      print('Successfully deleted crop with ID: $cropId');
    } catch (e) {
      errorMessage = "Failed to delete crop: $e";
      print("Error deleting crop: $e");
      notifyListeners();
    }
  }

}
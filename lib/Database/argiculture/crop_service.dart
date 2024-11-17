import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class CropService {
  Future<List<Map<String, dynamic>>> loadCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final cropsData = prefs.getString('crops');
    if (cropsData != null) {
      return (json.decode(cropsData) as List).map((crop) {
        return {
          "name": crop["name"],
          "definition": crop["definition"],
          "imagePath": crop["imagePath"] != null && crop["imagePath"].startsWith("data:image")
              ? base64Decode(crop["imagePath"].split(",")[1])
              : crop["imagePath"],
          "features": (crop["features"] as Map<String, dynamic>?)?.map((key, value) {
            return MapEntry(
              key,
              (value is List)
                  ? value.whereType<Map<String, dynamic>>().map((item) => Map<String, dynamic>.from(item)).toList()
                  : <Map<String, dynamic>>[], // Sử dụng danh sách trống nếu không đúng kiểu
            );
          }) ?? {},
        };
      }).toList();
    }
    return [];
  }
  Future<void> saveCrops(List<Map<String, dynamic>> crops) async {
    final prefs = await SharedPreferences.getInstance();
    final cropsData = crops.map((crop) {
      return {
        "name": crop["name"],
        "definition": crop["definition"],
        // Chuyển đổi Uint8List thành chuỗi Base64 để lưu trữ
        "imagePath": crop["imagePath"] is Uint8List
            ? "data:image/png;base64," + base64Encode(crop["imagePath"])
            : crop["imagePath"],
        "features": (crop["features"] as Map<String, dynamic>).map((key, value) {
          // Chuyển từng phần tử trong danh sách `features` thành `Map<String, dynamic>`
          return MapEntry(
            key,
            List<Map<String, dynamic>>.from(value.map((item) => Map<String, dynamic>.from(item))),
          );
        }),
      };
    }).toList();

    await prefs.setString('crops', json.encode(cropsData));
  }

  void addCrop(List<Map<String, dynamic>> crops, Map<String, dynamic> newCrop) {
    crops.add(newCrop);
  }

  void editCrop(List<Map<String, dynamic>> crops, int index, Map<String, dynamic> updatedCrop) {
    crops[index] = updatedCrop;
  }

  void deleteCrop(List<Map<String, dynamic>> crops, int index) {
    crops.removeAt(index);
  }
}

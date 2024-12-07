import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart'; // For loading the model from assets
import 'package:image/image.dart' as img; // Image package for image processing
import 'dart:convert'; // For JSON parsing
import 'package:camera/camera.dart';
class TipsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mẹo Chụp Ảnh Cây Trồng"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Mẹo để chụp ảnh cây trồng :",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "1. Đảm bảo ánh sáng tốt: Chụp ảnh dưới ánh sáng tự nhiên sẽ giúp hình ảnh sắc nét hơn.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "2. Đặt điện thoại vững vàng: Đảm bảo điện thoại không bị rung để hình ảnh không bị mờ.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "3. Đảm bảo đối tượng không bị cản trở: Đảm bảo đối tượng chính không bị vật gì cản trở khi chụp.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "4. Cẩn thận với độ phân giải: Chọn độ phân giải cao để ảnh rõ nét hơn khi phân tích.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "5. Tránh chụp ảnh quá xa hoặc quá gần: Cần chú ý đến khoảng cách chụp để tránh méo ảnh.",
              style: TextStyle(fontSize: 16),
            ),// Your tips here...
          ],
        ),
      ),
    );
  }
}

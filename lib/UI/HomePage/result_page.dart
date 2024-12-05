import 'package:flutter/material.dart';
import 'dart:io'; // Add this import
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart'; // For loading the model from assets
import 'package:image/image.dart' as img; // Image package for image processing
import 'dart:convert'; // For JSON parsing
import 'package:camera/camera.dart';


class ResultPage extends StatefulWidget {
  final String result;
  final File? image;
  final String symptom; // Symptom corresponding to the result
  final String xua;
  final String nhan;

  ResultPage({required this.result, required this.symptom, required this.xua, required this.nhan, required this.image});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kết quả"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.image != null
                  ? Image.file(widget.image!, fit: BoxFit.cover, height: 300, width: double.infinity)
                  : Container(),
              SizedBox(height: 20),
              Text(
                "Kết quả phân loại:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.result,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "1. Thường xuất hiện trên cây",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.xua, // Display the symptom
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "2. Triệu chứng",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.symptom, // Display the symptom
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "3. Nhận biết sâu hại",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.nhan, // Display the symptom
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 20),
              Image.asset('assets/img_3.png', fit: BoxFit.cover, height: 200, width: double.infinity),
              SizedBox(height: 20),
              Text(
                'A. Biện pháp trừ sâu bệnh an toàn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Biện pháp quan trọng nhất để đối phó với loại bệnh hại này là sử dụng các giống kháng bệnh hiện có để gieo trồng. '
                      'Lên kế hoạch luân canh với những cây không phải là ký chủ. '
                      '${_showMore ? 'Điều này sẽ giúp giảm thiểu sự lây lan và phòng ngừa bệnh hại phát triển trong tương lai.' : ''}',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showMore = !_showMore; // Toggle the state of _showMore
                  });
                },
                child: Text(
                  _showMore ? 'Thu gọn' : 'Xem thêm',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'B. Sử dụng thuốc bảo vệ thực vật',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bệnh chưa có thuốc điều trị, lưu ý phòng bệnh là chính.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

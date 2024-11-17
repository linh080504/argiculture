import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Để xử lý Base64
import 'package:weather/Amin/plants/step_form.dart';

class FeatureForm extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> initialSteps;
  final Function(List<Map<String, dynamic>>) onUpdate;

  const FeatureForm({
    required this.title,
    required this.onUpdate,
    this.initialSteps = const [],
    Key? key,
  }) : super(key: key);

  @override
  _FeatureFormState createState() => _FeatureFormState();
}

class _FeatureFormState extends State<FeatureForm> {
  late List<Map<String, dynamic>> steps;

  @override
  void initState() {
    super.initState();
    // Khởi tạo `steps` từ `initialSteps` để đảm bảo `imagePath` là `String` hoặc `Uint8List`
    steps = widget.initialSteps.map((step) {
      return {
        "content": step["content"] ?? "",
        // Kiểm tra nếu `imagePath` là `List`, đặt thành chuỗi trống hoặc xử lý thích hợp
        "imagePath": step["imagePath"] is List ? "" : step["imagePath"] ?? "",
      };
    }).toList();
  }

  void _addStep() {
    setState(() {
      // Thêm bước mới với `content` và `imagePath` trống
      steps.add({"content": "", "imagePath": ""});
      widget.onUpdate(List<Map<String, dynamic>>.from(steps)); // Gọi `onUpdate` với danh sách `steps` hiện tại
    });
  }

  void _updateStep(int index, Map<String, dynamic> updatedStep) {
    setState(() {
      // Cập nhật `step` tại vị trí `index` với giá trị mới của `content` và `imagePath`
      steps[index] = updatedStep;
      widget.onUpdate(List<Map<String, dynamic>>.from(steps)); // Gọi `onUpdate` với danh sách `steps` đã cập nhật
    });
  }

  void _removeStep(int index) {
    setState(() {
      steps.removeAt(index); // Xóa `step` tại vị trí `index`
      widget.onUpdate(List<Map<String, dynamic>>.from(steps)); // Gọi `onUpdate` với danh sách `steps` đã cập nhật
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ExpansionTile(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          children: [
            Column(
              children: List.generate(steps.length, (index) {
                final step = steps[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: StepForm(
                    initialContent: step["content"] ?? "",
                    initialImagePath: step["imagePath"] is Uint8List
                        ? "data:image/png;base64," + base64Encode(step["imagePath"])
                        : step["imagePath"] is String && step["imagePath"].startsWith("data:image")
                        ? step["imagePath"]
                        : "", // Chuyển thành chuỗi trống nếu không hợp lệ
                    onDelete: () => _removeStep(index), // Xóa bước khi nhấn nút xóa
                    onChanged: (updatedStep) {
                      _updateStep(index, {
                        "content": updatedStep["content"] ?? step["content"]!,
                        "imagePath": updatedStep["imagePath"] is String && updatedStep["imagePath"].startsWith("data:image")
                            ? base64Decode(updatedStep["imagePath"].split(",")[1])
                            : updatedStep["imagePath"] ?? step["imagePath"]!,
                      });
                    }, // Cập nhật bước khi có thay đổi
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add),
                label: const Text('Thêm bước'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

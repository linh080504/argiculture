import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class StepForm extends StatefulWidget {
  final String? initialContent;
  final dynamic initialImagePath; // Có thể là String hoặc Uint8List
  final Function onDelete;
  final Function(Map<String, dynamic>) onChanged;

  const StepForm({
    this.initialContent,
    this.initialImagePath,
    required this.onDelete,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _StepFormState createState() => _StepFormState();
}

class _StepFormState extends State<StepForm> {
  late TextEditingController contentController;
  File? imageFile;
  Uint8List? webImageBytes;

  @override
  void initState() {
    super.initState();
    contentController = TextEditingController(text: widget.initialContent);

    if (widget.initialImagePath != null) {
      if (kIsWeb && widget.initialImagePath is Uint8List) {
        // Nếu chạy trên web và `initialImagePath` là Uint8List, gán trực tiếp
        webImageBytes = widget.initialImagePath as Uint8List;
      } else if (!kIsWeb && widget.initialImagePath is String) {
        // Nếu là mobile và `initialImagePath` là đường dẫn, tạo File
        imageFile = File(widget.initialImagePath as String);
      } else if (widget.initialImagePath is String && widget.initialImagePath.startsWith("data:image")) {
        // Nếu `initialImagePath` là Base64 string trên web, giải mã thành Uint8List
        final base64Data = widget.initialImagePath.split(',')[1];
        webImageBytes = base64Decode(base64Data);
      }
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Đọc dữ liệu byte cho web và cập nhật webImageBytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          webImageBytes = bytes;
        });
        // Gọi hàm onChanged với dữ liệu Base64 cho web
        widget.onChanged({
          "content": contentController.text,
          "imagePath": "data:image/png;base64," + base64Encode(bytes), // Lưu dưới dạng Base64
        });
      } else {
        setState(() {
          imageFile = File(pickedFile.path);
        });
        widget.onChanged({
          "content": contentController.text,
          "imagePath": pickedFile.path, // Lưu dưới dạng đường dẫn cho mobile
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Nội dung bước',
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: null,
              onChanged: (text) {
                widget.onChanged({
                  "content": text,
                  "imagePath": kIsWeb
                      ? (webImageBytes != null ? "data:image/png;base64," + base64Encode(webImageBytes!) : null)
                      : imageFile?.path,
                });
              },
            ),
            const SizedBox(height: 12),
            if (kIsWeb && webImageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  webImageBytes!,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              )
            else if (!kIsWeb && imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile!,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Thêm hình ảnh'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 20.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () => widget.onDelete(),
                  tooltip: 'Xóa bước',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

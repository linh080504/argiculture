import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert'; // Để mã hóa và giải mã Base64
import 'package:flutter/foundation.dart';
import 'package:weather/Amin/plants/FeatureForm.dart';

class AddOrEditCropDialog extends StatefulWidget {
  final Map<String, dynamic>? crop;
  final Function(Map<String, dynamic>) onSave;

  AddOrEditCropDialog({this.crop, required this.onSave});

  @override
  _AddOrEditCropDialogState createState() => _AddOrEditCropDialogState();
}

class _AddOrEditCropDialogState extends State<AddOrEditCropDialog> {
  late TextEditingController nameController;
  late TextEditingController definitionController;
  Uint8List? webImageBytes; // Dùng để lưu ảnh dưới dạng bytes cho web
  File? selectedImageFile; // Dùng cho mobile
  late Map<String, List<Map<String, dynamic>>> features;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.crop?['name'] as String? ?? '');
    definitionController = TextEditingController(text: widget.crop?['definition'] as String? ?? '');

    // Kiểm tra và lấy hình ảnh (Uint8List cho web, String cho mobile)
    if (widget.crop != null && widget.crop!['imagePath'] != null) {
      if (kIsWeb && widget.crop!['imagePath'] is String && widget.crop!['imagePath'].startsWith("data:image")) {
        // Nếu là chuỗi Base64 trên web, giải mã thành Uint8List
        webImageBytes = base64Decode(widget.crop!['imagePath'].split(",")[1]);
      } else if (!kIsWeb) {
        selectedImageFile = File(widget.crop!['imagePath']);
      }
    }

    // Khởi tạo features
    features = (widget.crop?['features'] as Map<String, dynamic>? ?? {
      "Giới thiệu về giống": [],
      "Ngoại cảnh": [],
      "Nhân giống": [],
      "Trồng cây": [],
      "Chăm sóc cây": [],
      "Sâu bệnh hại": [],
      "Thu hoạch": [],
      "Canh tác": [],
    }).map((key, value) => MapEntry(
      key,
      List<Map<String, dynamic>>.from(
        (value as List).map((item) => {
          "content": item["content"] as String? ?? "",
          "imagePath": item["imagePath"] as String? ?? "",
        }),
      ),
    ));
  }

  @override
  void dispose() {
    nameController.dispose();
    definitionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        // Đọc file dưới dạng bytes cho web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          webImageBytes = bytes;
        });
      } else {
        // Dùng File cho mobile
        setState(() {
          selectedImageFile = File(pickedFile.path);
        });
      }
    }
  }

  void _updateFeature(String key, List<Map<String, dynamic>> updatedSteps) {
    setState(() {
      features[key] = updatedSteps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.crop == null ? 'Thêm cây trồng' : 'Chỉnh sửa cây trồng'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên cây trồng',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: definitionController,
                decoration: InputDecoration(
                  labelText: 'Định nghĩa',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (kIsWeb && webImageBytes != null)
                    Image.memory(
                      webImageBytes!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  else if (!kIsWeb && selectedImageFile != null)
                    Image.file(
                      selectedImageFile!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text("Chọn hình ảnh"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...features.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: FeatureForm(
                    title: entry.key,
                    initialSteps: entry.value,
                    onUpdate: (updatedSteps) => _updateFeature(entry.key, updatedSteps),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Hủy',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final newCrop = {
              'name': nameController.text,
              'definition': definitionController.text,
              'imagePath': kIsWeb && webImageBytes != null
                  ? "data:image/png;base64," + base64Encode(webImageBytes!) // Lưu thành Base64 cho web
                  : selectedImageFile?.path, // Lưu đường dẫn file cho mobile
              'features': features,
            };
            widget.onSave(newCrop);
            Navigator.of(context).pop();
          },
          child: Text(widget.crop == null ? 'Thêm' : 'Lưu'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

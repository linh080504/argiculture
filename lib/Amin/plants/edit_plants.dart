import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'crop_controller.dart';
import 'crop.dart';

class EditCropPage extends StatefulWidget {
  final String cropId;
  final CropController cropController;

  EditCropPage({required this.cropId, required this.cropController}); // Nhận cropId và cropController

  @override
  _EditCropPageState createState() => _EditCropPageState();
}

class _EditCropPageState extends State<EditCropPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String definition = '';
  File? cropImage;
  List<Map<String, dynamic>> introductionSteps = [];
  List<Map<String, dynamic>> environmentSteps = [];
  List<Map<String, dynamic>> propagationSteps = [];
  List<Map<String, dynamic>> plantingSteps = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCropData();
  }

  // Tải thông tin cây trồng từ Firestore
  Future<void> _loadCropData() async {
    try {
      final crop = await widget.cropController.getCropById(widget.cropId);
      setState(() {
        name = crop.name;
        definition = crop.definition;
        introductionSteps = crop.introductionSteps;
        environmentSteps = crop.environmentSteps;
        propagationSteps = crop.propagationSteps;
        plantingSteps = crop.plantingSteps;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải cây trồng: $e')));
    }
  }

  // Lưu thông tin cây trồng đã chỉnh sửa
  Future<void> _saveCrop() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Tải ảnh lên Firebase Storage nếu có
        String imageUrl = '';
        if (cropImage != null) {
          imageUrl = await widget.cropController.uploadImage(cropImage!, 'cropImages');
        }

        final crop = Crop(
          id: widget.cropId,
          name: name,
          definition: definition,
          imageUrl: imageUrl,
          introduction: 'Giới thiệu cây trồng',
          environment: 'Môi trường cây trồng',
          propagation: 'Cách nhân giống cây trồng',
          planting: 'Cách trồng cây',
          introductionSteps: introductionSteps,
          environmentSteps: environmentSteps,
          propagationSteps: propagationSteps,
          plantingSteps: plantingSteps,
        );

        // Lưu cây trồng và các ảnh liên quan vào Firestore
        await widget.cropController.updateCrop(crop);
        Navigator.pop(context); // Quay lại trang trước khi thành công
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu cây trồng: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa Cây Trồng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Ô TextField cho tên cây trồng
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Tên cây trồng'),
                onSaved: (value) => name = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập tên cây trồng';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Ô TextField cho định nghĩa cây trồng
              TextFormField(
                initialValue: definition,
                decoration: InputDecoration(labelText: 'Định nghĩa cây trồng'),
                onSaved: (value) => definition = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập định nghĩa cây trồng';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Trường upload ảnh cây trồng
              ElevatedButton(
                onPressed: _pickCropImage,
                child: Text(cropImage == null ? 'Chọn ảnh cây trồng' : 'Ảnh đã chọn'),
              ),
              if (cropImage != null)
                Image.file(cropImage!, width: 100, height: 100),
              SizedBox(height: 20),

              // Các phần của cây trồng, mỗi phần sẽ có các bước nhỏ kèm ảnh
              _buildStepSection('Giới thiệu cây trồng', introductionSteps, 'introduction'),
              _buildStepSection('Môi trường cây trồng', environmentSteps, 'environment'),
              _buildStepSection('Cách nhân giống cây trồng', propagationSteps, 'propagation'),
              _buildStepSection('Cách trồng cây', plantingSteps, 'planting'),

              // Nút lưu thông tin cây trồng
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCrop,
                child: Text('Lưu Cây Trồng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Xây dựng phần bước cho mỗi mục
  Widget _buildStepSection(String title, List<Map<String, dynamic>> stepsList, String section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: stepsList.length,
          itemBuilder: (context, index) {
            final step = stepsList[index];
            return ListTile(
              title: Text(step['description'] ?? 'Bước ${index + 1}'),
              subtitle: step['imageUrl'] != null
                  ? Image.network(step['imageUrl'], width: 50, height: 50)
                  : Text(''),
            );
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  // Chọn ảnh cây trồng
  Future<void> _pickCropImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        cropImage = File(image.path);
      });
    }
  }
}

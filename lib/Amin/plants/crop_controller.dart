import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'crop_controller.dart';
import 'crop.dart';

class AddCropPage extends StatefulWidget {
  final CropController cropController;

  final Crop? crop; // Tham số crop, có thể null nếu là trang thêm mới

  AddCropPage({required this.cropController, this.crop}); // Constructor nhận crop

  @override
  _AddCropPageState createState() => _AddCropPageState();
}

class _AddCropPageState extends State<AddCropPage> {
  final _formKey = GlobalKey<FormState>();
  String name = ''; // Khởi tạo giá trị mặc định cho name
  String definition = ''; // Khởi tạo giá trị mặc định cho definition

  // Biến lưu trữ ảnh cây trồng sau định nghĩa
  File? cropImage;

  // Các danh sách lưu trữ các bước cho mỗi phần
  List<Map<String, dynamic>> introductionSteps = [];
  List<Map<String, dynamic>> environmentSteps = [];
  List<Map<String, dynamic>> propagationSteps = [];
  List<Map<String, dynamic>> plantingSteps = [];

  // Danh sách ảnh cho từng bước
  List<File?> introductionImages = [];
  List<File?> environmentImages = [];
  List<File?> propagationImages = [];
  List<File?> plantingImages = [];

  final ImagePicker _picker = ImagePicker();

  // Chọn ảnh cây trồng sau định nghĩa
  Future<void> _pickCropImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        cropImage = File(image.path);
      });
    }
  }

  // Thêm một bước vào danh sách
  void _addStep(List<Map<String, dynamic>> stepsList, String section) {
    showDialog(
      context: context,
      builder: (context) {
        return StepForm(
          stepIndex: stepsList.length,
          section: section,
          onSave: (description, imageUrl) {
            setState(() {
              stepsList.add({'description': description, 'imageUrl': imageUrl});
              // Thêm ảnh vào danh sách ảnh tương ứng
              switch (section) {
                case 'introduction':
                  introductionImages.add(null); // Thêm null placeholder
                  break;
                case 'environment':
                  environmentImages.add(null);
                  break;
                case 'propagation':
                  propagationImages.add(null);
                  break;
                case 'planting':
                  plantingImages.add(null);
                  break;
              }
            });
          },
        );
      },
    );
  }

  // Lưu thông tin cây trồng vào Firestore và Storage
  Future<void> _saveCrop() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Tạo đối tượng Crop mới với các tham số bắt buộc
      final crop = Crop(
        id: DateTime.now().millisecondsSinceEpoch.toString(),  // Sử dụng mili giây
        name: name,
        definition: definition,
        imageUrl: '', // Để trống, sẽ cập nhật sau khi tải lên ảnh
        introduction: 'Giới thiệu cây trồng',
        environment: 'Môi trường cây trồng',
        propagation: 'Cách nhân giống cây trồng',
        planting: 'Cách trồng cây',
        introductionSteps: introductionSteps,
        environmentSteps: environmentSteps,
        propagationSteps: propagationSteps,
        plantingSteps: plantingSteps,
      );

      try {
        // Tải ảnh cây trồng lên Firebase Storage và lấy URL
        String cropImageUrl = '';
        if (cropImage != null) {
          cropImageUrl = await widget.cropController.uploadImage(cropImage!, 'crop_images');
        }
        crop.imageUrl = cropImageUrl;

        // Khởi tạo một map để lưu các ảnh cho từng phần
        Map<String, List<String>> stepImages = {};

        // Tải ảnh lên Firebase Storage và lấy URL cho từng phần
        await Future.forEach([
          {'section': 'introduction', 'images': introductionImages},
          {'section': 'environment', 'images': environmentImages},
          {'section': 'propagation', 'images': propagationImages},
          {'section': 'planting', 'images': plantingImages},
        ], (Map<String, dynamic> item) async {
          String section = item['section'];
          List<File?> images = item['images'];

          List<String> imageUrls = [];  // Dùng để lưu các URL ảnh

          for (var image in images) {
            if (image != null) {
              // 1. Tải ảnh lên Firebase Storage và lấy URL
              String imageUrl = await widget.cropController.uploadImage(image, section);
              imageUrls.add(imageUrl);
            }
          }

          // 2. Lưu danh sách URL ảnh vào map `stepImages` theo từng phần
          stepImages[section] = imageUrls;
        });

        // 3. Gửi thông tin cây trồng và các URL ảnh lên Firestore
        await widget.cropController.addCrop(crop, stepImages);
        Navigator.pop(context);  // Đóng trang khi thành công
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thêm cây trồng thất bại: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Cây Trồng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Tên cây trồng'),
                onSaved: (value) => name = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập tên cây trồng';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Định nghĩa cây trồng'),
                onSaved: (value) => definition = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Vui lòng nhập định nghĩa cây trồng';
                  }
                  return null;
                },
              ),
              // Trường upload ảnh cây trồng
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickCropImage,
                child: Text(cropImage == null ? 'Chọn ảnh cây trồng' : 'Ảnh đã chọn'),
              ),
              if (cropImage != null)
                Image.file(cropImage!, width: 100, height: 100),

              // Các phần của cây trồng, mỗi phần sẽ có các bước nhỏ kèm ảnh
              _buildStepSection('Giới thiệu cây trồng', introductionSteps, introductionImages, 'introduction'),
              _buildStepSection('Môi trường cây trồng', environmentSteps, environmentImages, 'environment'),
              _buildStepSection('Cách nhân giống cây trồng', propagationSteps, propagationImages, 'propagation'),
              _buildStepSection('Cách trồng cây', plantingSteps, plantingImages, 'planting'),

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
  Widget _buildStepSection(String title, List<Map<String, dynamic>> stepsList, List<File?> imageList, String section) {
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
                  : Icon(Icons.image),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    stepsList.removeAt(index);
                    imageList.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _addStep(stepsList, section),
          child: Text('Thêm bước vào $title'),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class StepForm extends StatefulWidget {
  final int stepIndex;
  final String section;
  final Function(String, String?) onSave;  // Lưu URL thay vì File

  StepForm({required this.stepIndex, required this.section, required this.onSave});

  @override
  _StepFormState createState() => _StepFormState();
}

class _StepFormState extends State<StepForm> {
  late TextEditingController _descriptionController;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Hàm tải ảnh lên Firebase Storage và lấy URL
  Future<String?> _uploadImage(File image) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance.ref().child('steps/${widget.section}/$fileName');

      final UploadTask uploadTask = storageRef.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nhập thông tin chi tiết bước'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Mô tả bước'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text(_image == null ? 'Chọn ảnh' : 'Đổi ảnh'),
          ),
          if (_image != null)
            Image.file(_image!, width: 100, height: 100),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            // Tải ảnh lên Firebase Storage và lấy URL
            String? imageUrl = _image != null ? await _uploadImage(_image!) : null;

            // Gọi onSave với mô tả và URL ảnh
            widget.onSave(_descriptionController.text, imageUrl);
            Navigator.pop(context);
          },
          child: Text('Lưu'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
        ),
      ],
    );
  }
}

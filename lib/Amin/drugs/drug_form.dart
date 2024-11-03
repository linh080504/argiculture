import 'dart:io';
import 'dart:typed_data'; // Thêm import cho Uint8List
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weather/Database/argiculture/drug_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DrugForm extends StatefulWidget {
  final String? drugId;
  const DrugForm({Key? key, this.drugId}) : super(key: key);

  @override
  State<DrugForm> createState() => _DrugFormState();
}

class _DrugFormState extends State<DrugForm> {
  final DrugService _drugService = DrugService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _activeIngredientController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _formController = TextEditingController();
  final TextEditingController _usageController = TextEditingController();
  final TextEditingController _warningsController = TextEditingController();
  final TextEditingController _safetyRecommendationsController = TextEditingController();

  File? _selectedImage; // Lưu ảnh dưới dạng File cho ứng dụng di động
  Uint8List? _webImageBytes; // Lưu ảnh dưới dạng Uint8List cho nền tảng web
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.drugId != null) {
      _loadDrugData();
    }
  }

  Future<void> _loadDrugData() async {
    final doc = await _drugService.getDrugById(widget.drugId!);
    if (doc != null) {
      _nameController.text = doc['name'] ?? '';
      _companyController.text = doc['company'] ?? '';
      _typeController.text = doc['type'] ?? '';
      _activeIngredientController.text = doc['activeIngredient'] ?? '';
      _dosageController.text = doc['dosage'] ?? '';
      _formController.text = doc['form'] ?? '';
      _usageController.text = doc['usage'] ?? '';
      _warningsController.text = doc['warnings'] ?? '';
      _safetyRecommendationsController.text = doc['safetyRecommendations'] ?? '';
      _imageUrl = doc['imageUrl'] ?? '';
      setState(() {});
    } else {
      print('Không tìm thấy tài liệu cho drugId: ${widget.drugId}');
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Xử lý cho nền tảng web
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.isNotEmpty) {
          _webImageBytes = result.files.first.bytes; // Lưu ảnh dưới dạng Uint8List
          final fileName = result.files.first.name;

          if (_webImageBytes != null) {
            setState(() {
              _imageUrl = null;
            });

            // Upload ảnh lên Firestore
            _imageUrl = await _drugService.uploadImage(_webImageBytes!, fileName);
            if (_imageUrl!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Có lỗi xảy ra khi tải lên ảnh.')));
            }
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Không có ảnh nào được chọn.')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không có ảnh nào được chọn.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Có lỗi xảy ra khi chọn ảnh: $e')));
      }
    } else {
      // Xử lý cho app di động
      try {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });

          // Đọc byte từ ảnh và tải lên Firestore
          final bytes = await pickedFile.readAsBytes();
          _imageUrl = await _drugService.uploadImage(bytes, pickedFile.name);
          if (_imageUrl!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Có lỗi xảy ra khi tải lên ảnh.')));
          }
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không có ảnh nào được chọn.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Có lỗi xảy ra khi chọn ảnh: $e')));
      }
    }
  }

  void _submitForm() async {
    if (_selectedImage != null) {
      try {
        final bytes = await _selectedImage!.readAsBytes();
        _imageUrl = await _drugService.uploadImage(bytes, _selectedImage!.path.split('/').last);
      } catch (e) {
        print("Lỗi tải ảnh: $e");
      }
    }

    final drugData = {
      'name': _nameController.text,
      'company': _companyController.text,
      'type': _typeController.text,
      'activeIngredient': _activeIngredientController.text,
      'dosage': _dosageController.text,
      'form': _formController.text,
      'usage': _usageController.text,
      'warnings': _warningsController.text,
      'safetyRecommendations': _safetyRecommendationsController.text,
      'imageUrl': _imageUrl ?? '',
    };

    try {
      if (widget.drugId != null) {
        await _drugService.updateDrug(widget.drugId!, drugData);
      } else {
        await _drugService.addDrug(drugData);
      }
      Navigator.of(context).pop();
    } catch (e) {
      print("Lỗi thêm hoặc cập nhật thuốc: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.drugId == null ? 'Thêm thuốc mới' : 'Cập nhật thuốc',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTextField(_nameController, 'Tên thuốc'),
            _buildTextField(_companyController, 'Công ty'),
            _buildTextField(_typeController, 'Loại thuốc'),
            _buildTextField(_activeIngredientController, 'Hoạt chất'),
            _buildTextField(_dosageController, 'Hàm lượng'),
            _buildTextField(_formController, 'Dạng thuốc'),
            _buildTextField(_usageController, 'Công dụng'),
            _buildTextField(_warningsController, 'Cảnh báo'),
            _buildTextField(_safetyRecommendationsController, 'Khuyến nghị an toàn'),
            SizedBox(height: 16),
            if (_webImageBytes != null) ...[ // Nếu đang chạy trên web và có ảnh dưới dạng Uint8List
              Image.memory(_webImageBytes!, height: 150, fit: BoxFit.cover),
            ] else if (_selectedImage != null) ...[ // Nếu có ảnh đã chọn cho app
              Text(
                _selectedImage!.path.split('/').last,
                style: TextStyle(color: Colors.blue),
              ),
              Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
            ] else if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[ // Nếu có URL ảnh
              SizedBox(height: 8),
              Image.network(_imageUrl!, height: 150, fit: BoxFit.cover),
            ] else ...[ // Hiển thị nút chọn ảnh nếu không có ảnh nào
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(child: Text('Chọn ảnh', style: TextStyle(color: Colors.blue))),
                ),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.drugId == null ? 'Thêm' : 'Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

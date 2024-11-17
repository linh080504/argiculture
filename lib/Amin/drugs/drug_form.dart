import 'dart:io';
import 'dart:typed_data';
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

  File? _selectedImage;
  Uint8List? _webImageBytes;
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
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.isNotEmpty) {
          _webImageBytes = result.files.first.bytes;
          final fileName = result.files.first.name;

          if (_webImageBytes != null) {
            setState(() {
              _imageUrl = null;
            });
            _imageUrl = await _drugService.uploadImage(_webImageBytes!, fileName);
            if (_imageUrl!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra khi tải lên ảnh.')));
            }
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không có ảnh nào được chọn.')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không có ảnh nào được chọn.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra khi chọn ảnh: $e')));
      }
    } else {
      try {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });

          final bytes = await pickedFile.readAsBytes();
          _imageUrl = await _drugService.uploadImage(bytes, pickedFile.name);
          if (_imageUrl!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra khi tải lên ảnh.')));
          }
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không có ảnh nào được chọn.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra khi chọn ảnh: $e')));
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
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.drugId == null ? 'Thêm thuốc mới' : 'Cập nhật thuốc',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(_nameController, 'Tên thuốc'),
            _buildTextField(_companyController, 'Công ty'),
            _buildTextField(_typeController, 'Loại thuốc'),
            _buildTextField(_activeIngredientController, 'Hoạt chất'),
            _buildTextField(_dosageController, 'Hàm lượng'),
            _buildTextField(_formController, 'Dạng thuốc'),
            _buildTextField(_usageController, 'Công dụng'),
            _buildTextField(_warningsController, 'Cảnh báo'),
            _buildTextField(_safetyRecommendationsController, 'Khuyến nghị an toàn'),
            SizedBox(height: 20),
            if (_webImageBytes != null)
              Image.memory(_webImageBytes!, height: 150, fit: BoxFit.cover),
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
            if (_imageUrl != null && _imageUrl!.isNotEmpty)
              Image.network(_imageUrl!, height: 150, fit: BoxFit.cover),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image, color: Colors.white),
                label: Text('Chọn ảnh', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.drugId == null ? 'Thêm' : 'Cập nhật'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}

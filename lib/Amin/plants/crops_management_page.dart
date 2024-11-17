import 'package:flutter/material.dart';
import 'package:weather/Database/argiculture/crop_service.dart';
import 'crop_card.dart';
import 'add_edit_crop_dialog.dart';

class CropsManagementPage extends StatefulWidget {
  const CropsManagementPage({super.key});

  @override
  State<CropsManagementPage> createState() => _CropsManagementPageState();
}

class _CropsManagementPageState extends State<CropsManagementPage> {
  List<Map<String, dynamic>> crops = [];
  final CropService _cropService = CropService();

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    final loadedCrops = await _cropService.loadCrops();
    setState(() {
      // Đảm bảo mọi phần tử trong crops là Map<String, dynamic>
      crops = List<Map<String, dynamic>>.from(
          loadedCrops.map((crop) => Map<String, dynamic>.from(crop))
      );
    });
  }


  Future<void> _saveCrops() async {
    await _cropService.saveCrops(crops);
  }

  void _addOrEditCrop({Map<String, dynamic>? crop, int? index}) {
    showDialog(
      context: context,
      builder: (context) {
        return AddOrEditCropDialog(
          crop: crop,
          onSave: (newCrop) {
            setState(() {
              if (index == null) {
                // Thêm cây trồng mới
                _cropService.addCrop(crops, newCrop);
              } else {
                // Cập nhật cây trồng đã có
                _cropService.editCrop(crops, index, newCrop);
              }
            });
            _saveCrops(); // Lưu dữ liệu sau khi cập nhật
          },
        );
      },
    );
  }

  void _deleteCrop(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa cây trồng'),
        content: const Text('Bạn có chắc chắn muốn xóa cây trồng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cropService.deleteCrop(crops, index);
              });
              Navigator.of(context).pop();
              _saveCrops(); // Lưu sau khi xóa
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý cây trồng'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          return CropCard(
            crop: crops[index],
            onEdit: () => _addOrEditCrop(
              crop: crops[index],
              index: index,
            ),
            onDelete: () => _deleteCrop(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditCrop(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

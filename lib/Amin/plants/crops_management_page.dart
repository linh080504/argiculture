import 'package:flutter/material.dart';
import 'crop_controller.dart';
import 'add_crop_page.dart';
import 'crop.dart';

class CropsManagementPage extends StatefulWidget {
  final CropController cropController;

  CropsManagementPage({required this.cropController});

  @override
  _CropsManagementPageState createState() => _CropsManagementPageState();
}

class _CropsManagementPageState extends State<CropsManagementPage> {
  late Future<void> _loadCropsFuture;

  @override
  void initState() {
    super.initState();
    _loadCropsFuture = widget.cropController.loadCrops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản Lý Cây Trồng')),
      body: FutureBuilder<void>(
        future: _loadCropsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || widget.cropController.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || widget.cropController.errorMessage.isNotEmpty) {
            return Center(child: Text('Lỗi: ${widget.cropController.errorMessage}'));
          } else if (widget.cropController.crops.isEmpty) {
            return Center(child: Text('Chưa có cây trồng nào.'));
          }

          return ListView.builder(
            itemCount: widget.cropController.crops.length,
            itemBuilder: (context, index) {
              final crop = widget.cropController.crops[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: crop.imageUrl.isNotEmpty
                      ? Image.network(crop.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50),
                  title: Text(crop.name),
                  subtitle: Text(crop.definition),
                  onTap: () async {
                    // Chuyển tới trang sửa cây trồng
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCropPage(cropController: widget.cropController, crop: crop),
                      ),
                    );
                    // Sau khi trở lại, tải lại danh sách cây trồng
                    setState(() {
                      _loadCropsFuture = widget.cropController.loadCrops();
                    });
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Xác nhận xóa cây trồng
                      bool? confirmDelete = await _confirmDelete(context);
                      if (confirmDelete == true) {
                        await widget.cropController.deleteCrop(crop.id);
                        // Tải lại danh sách cây trồng
                        setState(() {
                          _loadCropsFuture = widget.cropController.loadCrops();
                        });
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
        floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Chuyển tới trang thêm cây trồng
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCropPage(cropController: widget.cropController),
            ),
          );
          // Sau khi trở lại, tải lại danh sách cây trồng
          setState(() {
            _loadCropsFuture = widget.cropController.loadCrops();
          });
        },
      ),
    );
  }

  // Xác nhận xóa cây trồng
  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác Nhận Xóa'),
        content: Text('Bạn có chắc chắn muốn xóa cây trồng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

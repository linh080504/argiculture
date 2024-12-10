import 'package:flutter/material.dart';
import 'crop_controller.dart';
import 'add_crop_page.dart';
import 'crop.dart';
import 'edit_plants.dart';

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
  final CropController cropController = CropController();
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
                child: Column(
                  children: [
                    ListTile(
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
                            builder: (context) => EditCropPage(cropId: crop.id, // Truyền cropId
                              cropController: cropController),
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
                    _buildCropDetailsSection(crop), // Gọi hàm này để hiển thị chi tiết cây trồng
                  ],
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
        title: Text('Xác Nhận Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa cây trồng này?', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Tạo widget hiển thị thông tin các phần cây trồng (Giới thiệu, Môi trường, Cách trồng...)
  Widget _buildCropDetailsSection(Crop crop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Giới thiệu cây trồng
        ExpansionTile(
          title: Text('Giới thiệu cây trồng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            ListTile(
              title: Text(crop.introduction ?? 'Không có thông tin'),
            ),
          ],
        ),

        // Môi trường cây trồng
        ExpansionTile(
          title: Text('Môi trường cây trồng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            ListTile(
              title: Text(crop.environment ?? 'Không có thông tin'),
            ),
          ],
        ),

        // Cách nhân giống cây trồng
        ExpansionTile(
          title: Text('Cách nhân giống cây trồng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            ListTile(
              title: Text(crop.propagation ?? 'Không có thông tin'),
            ),
          ],
        ),

        // Cách trồng cây
        ExpansionTile(
          title: Text('Cách trồng cây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          children: [
            ListTile(
              title: Text(crop.planting ?? 'Không có thông tin'),
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CropCard extends StatelessWidget {
  final Map<String, dynamic> crop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CropCard({
    required this.crop,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: _buildImageWidget(),
            ),
            const SizedBox(height: 10),
            Text(
              crop['name'] ?? 'Không có tên',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              crop['definition'] ?? 'Không có mô tả',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (crop['features'] as Map<String, dynamic>?)?.entries.map<Widget>((entry) {
                // Kiểm tra kiểu dữ liệu `entry.value`
                final contentList = (entry.value is List<Map<String, dynamic>>)
                    ? List<Map<String, String>>.from(
                  entry.value.map((item) => Map<String, String>.from(item)),
                )
                    : <Map<String, String>>[];

                return _buildFeatureButton(
                  context,
                  entry.key,
                  contentList,
                );
              }).toList() ?? [],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    final imagePath = crop['imagePath'];
    if (imagePath != null) {
      if (imagePath is Uint8List) {
        return Image.memory(
          imagePath,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
        );
      } else if (imagePath is String) {
        if (imagePath.startsWith("data:image")) {
          try {
            final base64Data = imagePath.split(',')[1];
            final bytes = base64Decode(base64Data);
            return Image.memory(
              bytes,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
            );
          } catch (e) {
            return _buildDefaultImage();
          }
        } else if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
          return Image.network(
            imagePath,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
          );
        } else {
          try {
            return Image.file(
              File(imagePath),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
            );
          } catch (e) {
            return _buildDefaultImage();
          }
        }
      } else {
        return _buildDefaultImage();
      }
    }
    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return const Icon(Icons.image, size: 150, color: Colors.grey);
  }

  Widget _buildFeatureButton(
      BuildContext context, String title, List<Map<String, String>> contentList) {
    String content = contentList.map((step) => step['content'] ?? "").join("\n");

    return ElevatedButton(
      onPressed: () {
        _showFeatureDetail(context, title, content);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade100,
        foregroundColor: Colors.green.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _showFeatureDetail(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content.isNotEmpty ? content : 'Không có nội dung'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

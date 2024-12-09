import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DrugListItem extends StatelessWidget {
  final Map<String, dynamic> drug;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  DrugListItem({
    required this.drug,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (drug['imageUrl'] != null && drug['imageUrl'] != '')
                  _buildImage(drug['imageUrl']),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    drug['name'] ?? 'Tên không có sẵn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Công ty: ${drug['company'] ?? 'Không có sẵn'}'),
            Text('Loại thuốc: ${drug['type'] ?? 'Không có sẵn'}'),
            Text('Hoạt chất: ${drug['activeIngredient'] ?? 'Không có sẵn'}'),
            Text('Hàm lượng: ${drug['dosage'] ?? 'Không có sẵn'}'),
            Text('Dạng thuốc: ${drug['form'] ?? 'Không có sẵn'}'),
            SizedBox(height: 8),
            Text(
              'Công dụng: ${drug['usage'] ?? 'Không có sẵn'}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 4),
            Text(
              'Cảnh báo: ${drug['warnings'] ?? 'Không có sẵn'}',
              style: TextStyle(color: Colors.red[300]),
            ),
            SizedBox(height: 4),
            Text(
              'Khuyến nghị an toàn: ${drug['safetyRecommendations'] ?? 'Không có sẵn'}',
              style: TextStyle(color: Colors.orange[300]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(dynamic imageUrl) {
    if (imageUrl is Uint8List) {
      return Image.memory(
        imageUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
      );
    } else if (imageUrl is String && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          }
        },
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $error");
          return Icon(Icons.error);
        },
      );
    } else {
      return SizedBox(
        height: 60,
        width: 60,
        child: Icon(Icons.image, color: Colors.grey),
      );
    }
  }
}


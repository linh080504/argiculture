import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Database/argiculture/drug_service.dart';
import 'drug_form.dart';

class DrugsManagementPage extends StatefulWidget {
  @override
  _DrugsManagementPageState createState() => _DrugsManagementPageState();
}

class _DrugsManagementPageState extends State<DrugsManagementPage> {
  final DrugService _drugService = DrugService();
  List<dynamic> _drugs = [];

  @override
  void initState() {
    super.initState();
    _loadDrugs();
  }

  Future<void> _loadDrugs() async {
    final drugs = await _drugService.getAllDrugs();
    setState(() {
      _drugs = drugs;
    });
  }

  void _openForm({String? drugId}) {
    showDialog(
      context: context,
      builder: (context) => DrugForm(drugId: drugId),
    ).then((_) => _loadDrugs());
  }

  void _deleteDrug(String drugId) async {
    await _drugService.deleteDrug(drugId);
    _loadDrugs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý thuốc'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _drugs.length,
        itemBuilder: (context, index) {
          final drug = _drugs[index];
          return DrugListItem(
            drug: drug,
            onEdit: () => _openForm(drugId: drug['id']),
            onDelete: () => _deleteDrug(drug['id']),
          );
        },
      ),
    );
  }
}

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
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
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

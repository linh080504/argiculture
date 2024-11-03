import 'package:flutter/material.dart';

class DrugListItem extends StatelessWidget {
  final dynamic drug;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DrugListItem({
    Key? key,
    required this.drug,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(drug['name']),
      subtitle: Text(drug['company']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Xác nhận xóa'),
                  content: Text('Bạn có chắc chắn muốn xóa thuốc này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        onDelete();
                        Navigator.of(context).pop();
                      },
                      child: Text('Xóa'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

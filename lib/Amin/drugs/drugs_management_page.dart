import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weather/Amin/drugs/drug_list_item.dart';
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


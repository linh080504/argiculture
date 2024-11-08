import 'package:flutter/material.dart';

class ExpertPage extends StatefulWidget {

  const ExpertPage({super.key});

  @override
  _ExpertPageState createState() => _ExpertPageState();
}

class _ExpertPageState extends State<ExpertPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Đội ngũ chuyên gia',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 28,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text('Card 1'),
                subtitle: Text('Đây là nội dung của card 1'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Card 2'),
                subtitle: Text('Đây là nội dung của card 2'),
              ),
            ),
            // Thêm nhiều card khác vào đây
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'classifier.dart';
import 'crop_recommendation_form.dart';

class CropPage extends StatefulWidget {
  const CropPage({Key? key}) : super(key: key);

  @override
  _CropPageState createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  late Future<Classifier> _classifierFuture;

  @override
  void initState() {
    super.initState();
    _classifierFuture = Classifier.create();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khuyến nghị cây trồng'),
      ),
      body: FutureBuilder<Classifier>(
        future: _classifierFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            return CropRecommendationForm(classifier: snapshot.data!);
          } else {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
        },
      ),
    );
  }
}
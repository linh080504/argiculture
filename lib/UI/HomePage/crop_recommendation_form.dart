import 'package:flutter/material.dart';
import 'classifier.dart';
import 'recommendation_result_page.dart';

class CropRecommendationForm extends StatefulWidget {
  final Classifier classifier;

  CropRecommendationForm({required this.classifier});

  @override
  _CropRecommendationFormState createState() => _CropRecommendationFormState();
}

class _CropRecommendationFormState extends State<CropRecommendationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTextField(_nController, 'Nitrogen (N) in soil (kg/ha)', 0, 140),
            _buildTextField(_pController, 'Phosphorous (P) in soil (kg/ha)', 5, 145),
            _buildTextField(_kController, 'Potassium (K) in soil (kg/ha)', 5, 205),
            _buildTextField(_temperatureController, 'Temperature (°C)', 8, 44),
            _buildTextField(_humidityController, 'Humidity (%)', 14, 100),
            _buildTextField(_phController, 'pH value of the soil', 3, 10),
            _buildTextField(_rainfallController, 'Rainfall (mm)', 20, 300),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Replace 'primary' with 'backgroundColor'
                foregroundColor: Colors.white,  // Replace 'onPrimary' with 'foregroundColor'
                minimumSize: Size(double.infinity, 50),
              ),
              child: const Text('Recommend Crop'),
              onPressed: _recommendCrop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, double min, double max) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          double? inputValue = double.tryParse(value);
          if (inputValue == null) {
            return 'Please enter a valid number';
          }
          if (inputValue < min || inputValue > max) {
            return 'Please enter a value between $min and $max';
          }
          return null;
        },
      ),
    );
  }

  void _recommendCrop() async {
    if (_formKey.currentState!.validate()) {
      final inputs = {
        'N': double.parse(_nController.text),
        'P': double.parse(_pController.text),
        'K': double.parse(_kController.text),
        'temperature': double.parse(_temperatureController.text),
        'humidity': double.parse(_humidityController.text),
        'ph': double.parse(_phController.text),
        'rainfall': double.parse(_rainfallController.text),
      };

      try {
        final result = await widget.classifier.classify(
          inputs['N']!,
          inputs['P']!,
          inputs['K']!,
          inputs['temperature']!,
          inputs['humidity']!,
          inputs['ph']!,
          inputs['rainfall']!,
        );

        if (result.startsWith("Error:")) {
          _showErrorDialog(result);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RecommendationResultPage(
                recommendedCrops: [result],
                inputs: inputs,
              ),
            ),
          );
        }
      } catch (e) {
        print('Error in _recommendCrop: $e');
        _showErrorDialog('An unexpected error occurred: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
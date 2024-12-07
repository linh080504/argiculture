import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  final String _modelFile = 'assets/crop_recommendation_model.tflite';
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // These should match your Python labels_list
  final List<String> _labels = [
    "jute", "mango", "chickpea", "kidneybeans", "pigeonpeas",
    "coffee", "mungbean", "blackgram", "lentil", "pomegranate",
    "banana", "maize", "grapes", "watermelon", "muskmelon",
    "apple", "orange", "papaya", "coconut", "cotton",
    "rice", "mothbeans"
  ];

  // These should match your Python scaler mean_ and scale_ attributes
  final List<double> _scalerMean = [
    50.551111, 53.362963, 48.149206, 25.617195, 71.481481,
    6.468876, 103.463492
  ];
  final List<double> _scalerScale = [
    36.917164, 32.985883, 50.647931, 5.444181, 22.263814,
    0.773938, 54.942307
  ];

  Classifier._();

  static Future<Classifier> create() async {
    final classifier = Classifier._();
    await classifier._loadModel();
    return classifier;
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelFile);
      _isModelLoaded = true;
      print('Interpreter loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      _isModelLoaded = false;
    }
  }

  List<double> _scaleInput(List<double> input) {
    List<double> scaled = [];
    for (int i = 0; i < input.length; i++) {
      scaled.add((input[i] - _scalerMean[i]) / _scalerScale[i]);
    }
    return scaled;
  }

  Future<String> classify(double N, double P, double K, double temperature, double humidity, double ph, double rainfall) async {
    if (!_isModelLoaded) {
      print('Model not loaded. Attempting to load...');
      await _loadModel();
      if (!_isModelLoaded) {
        print('Model still not loaded after attempt');
        return "Error: Model not loaded";
      }
    }

    List<double> input = [N, P, K, temperature, humidity, ph, rainfall];
    List<double> scaledInput = _scaleInput(input);
    print('Scaled input: $scaledInput');

    var output = List<List<double>>.filled(1, List<double>.filled(_labels.length, 0));

    try {
      _interpreter!.run([scaledInput], output);
      print('Raw output: ${output[0]}');

      int predictedIndex = output[0].indexOf(output[0].reduce(max));
      String predictedCrop = _labels[predictedIndex];

      return predictedCrop;
    } catch (e) {
      print('Error during inference: $e');
      return "Error during prediction: $e";
    }
  }
}
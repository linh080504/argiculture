import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart'; // For loading the model from assets
import 'package:image/image.dart' as img; // Image package for image processing
import 'package:camera/camera.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/UI/HomePage/result_page.dart';
import 'package:weather/UI/HomePage/tips_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  Interpreter? _interpreter; // TensorFlow Lite interpreter
  List<String>? _labels; // List of class labels from the model
  bool _isLoading = false; // Flag to show loading indicator
  String _result = "Tap to Scan"; // Result text
  List<String>? _symptoms;
  List<String>? _xua;
  List<String>? _nhan;


  @override
  void initState() {
    super.initState();
    _loadModel(); // Load the model on app startup
    _loadLabels(); // Load the labels from the asset file
    _loadSymptoms();
    _loadXua();
    _loadNhan();
  }

  // Function to load the TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      final modelData = await rootBundle.load('assets/plant_disease_model.tflite');
      final modelBytes = modelData.buffer.asUint8List();
      _interpreter = Interpreter.fromBuffer(modelBytes); // Initialize the interpreter
      print("Model loaded successfully.");
    } catch (e) {
      print("Error loading model: $e");
      setState(() {
        _result = "Failed to load model";
      });
    }
  }

  // Function to load the labels for the classes
  Future<void> _loadLabels() async {
    try {
      final labelsFile = await rootBundle.loadString('assets/class_names.txt');
      _labels = labelsFile.split('\n'); // Split the labels by newline
    } catch (e) {
      print("Error loading labels: $e");
      setState(() {
        _result = "Failed to load labels";
      });
    }
  }
  // Load the symptoms from triệu_chứng.txt
  Future<void> _loadSymptoms() async {
    try {
      final symptomsFile = await rootBundle.loadString('assets/chung.txt');
      _symptoms = symptomsFile.split('\n');
    } catch (e) {
      print("Error loading symptoms: $e");
      setState(() {
        _result = "Failed to load symptoms";
      });
    }
  }
  // Load the symptoms from triệu_chứng.txt
  Future<void> _loadXua() async {
    try {
      final xuaFile = await rootBundle.loadString('assets/xua.txt');
      _xua = xuaFile.split('\n');
    } catch (e) {
      print("Error loading symptoms: $e");
      setState(() {
        _result = "Failed to load symptoms";
      });
    }
  }
  // Load the symptoms from triệu_chứng.txt
  Future<void> _loadNhan() async {
    try {
      final nhanFile = await rootBundle.loadString('assets/nhan.txt');
      _nhan = nhanFile.split('\n');
    } catch (e) {
      print("Error loading symptoms: $e");
      setState(() {
        _result = "Failed to load symptoms";
      });
    }
  }
  // Function to preprocess the image (resize and normalize)
  Future<List<List<List<List<double>>>>> _preprocessImage(File image) async {
    final bytes = await image.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);

    // Resize the image to the size required by the model (224x224)
    img.Image resizedImage = img.copyResize(originalImage!, width: 224, height: 224);

    List<List<List<List<double>>>> inputImage = List.generate(1, (index) {
      return List.generate(224, (y) {
        return List.generate(224, (x) {
          int pixel = resizedImage.getPixel(x, y);
          return [
            (img.getRed(pixel) / 255.0), // Normalize Red channel
            (img.getGreen(pixel) / 255.0), // Normalize Green channel
            (img.getBlue(pixel) / 255.0)   // Normalize Blue channel
          ];
        });
      });
    });

    return inputImage;
  }

  // Function for image classification
  Future<void> imageClassification(File image) async {
    var inputImage = await _preprocessImage(image);
    var output = List.filled(38, 0.0).reshape([1, 38]); // Output shape for 38 classes

    _interpreter!.run(inputImage, output);

    List<double> outputList = List<double>.from(output[0]);

    double maxConfidence = outputList.reduce((a, b) => a > b ? a : b);
    final predictionIndex = outputList.indexOf(maxConfidence);
    final predictedLabel = _labels![predictionIndex];
    final predictedSymptom = _symptoms![predictionIndex];
    final predictedXua = _xua![predictionIndex];
    final predictedNhan = _nhan![predictionIndex];

    setState(() {
      _isLoading = false;
    });

    // Chuyển đến ResultPage với kết quả
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          result: "Prediction: $predictedLabel with confidence: $maxConfidence",
          symptom: predictedSymptom,
          xua: predictedXua,
          nhan: predictedNhan,
          image: image,
        ),
      ),
    ).then((_) {
      // Reset image after returning from ResultPage
      setState(() {
        _image = null;  // Clear the image when returning from ResultPage
      });
    });
  }
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      print("Image picked: ${pickedFile.path}"); // Check if the image path is printed
      setState(() {
        _isLoading = true; // Set loading state to true
        _image = File(pickedFile.path); // Store the picked image
      });
      await imageClassification(_image!); // Run the classification
    } else {
      print("No image picked");
    }
  }

  // Show a dialog to choose between camera or gallery
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose Image Source"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _pickImage(ImageSource.camera); // Pick image from camera
              },
              child: Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _pickImage(ImageSource.gallery); // Pick image from gallery
              },
              child: Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _interpreter?.close(); // Close the interpreter when the page is disposed
    super.dispose();
  }

  @override
  void _navigateToTipsPage() {
    print("Navigating to TipsPage");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TipsPage()), // Điều hướng tới trang TipsPage
    );
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close the current page
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.green.withOpacity(.15),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.green,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint('favorite'); // Placeholder for favorite action
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.green.withOpacity(.15),
                    ),
                    child: Icon(
                      Icons.share,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 150,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: size.width * 0.7,  // Kích thước chiều rộng nhỏ lại
                    height: size.width * 0.7, // Kích thước chiều cao nhỏ lại, đảm bảo vuông
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                      color: Colors.green.withOpacity(0.1),
                    ),
                    child: _image == null
                        ? Center(
                      child: Icon(Icons.camera_alt, size: 80, color: Colors.green),
                    )
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 20),
                // Thay thế chữ "animation:" bằng animation Lottie
                Lottie.asset('assets/Animation.json', width: 200, height: 200),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _navigateToTipsPage, // Khi nhấn vào "Mẹo chụp ảnh", chuyển sang TipsPage
                  child: Text(
                    "Mẹo chụp hình: Hãy đảm bảo hình ảnh rõ nét và không bị mờ.",
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.green),
                  ),
                ),
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : Column(
                  children: [
                    Text(
                      _result,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_result != "Tap to Scan")
                      GestureDetector(
                        onTap: _navigateToTipsPage,
                        child: Text(
                          "Mẹo chụp ảnh: Hãy đảm bảo hình ảnh rõ nét và không bị mờ.",
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

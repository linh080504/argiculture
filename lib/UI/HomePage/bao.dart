import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BaoPage extends StatefulWidget {
  const BaoPage({Key? key}) : super(key: key);

  @override
  _BaoPageState createState() => _BaoPageState();
}

class _BaoPageState extends State<BaoPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    // Khởi tạo WebView
    controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://www.windy.com/'));
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theo dõi bão'),
      ),
      body: WebViewWidget(controller: controller,)
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/Amin/admin_page.dart';
import 'package:weather/Onboboarding/onboarding_view.dart';
import 'package:weather/Amin/admin_page.dart'; // Đảm bảo import AdminPage
import 'package:weather/UI/home.dart';
import 'package:weather/UI/login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool("onboarding") ?? false;
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // Kiểm tra trạng thái đăng nhập

  runApp(MyApp(onboarding: onboarding, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  final bool isLoggedIn; // Thêm biến để kiểm tra trạng thái đăng nhập

  const MyApp({super.key, this.onboarding = false, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      routes: {
        '/signin': (context) => const SignInPage(), // Đăng ký route cho SignInPage

        // Bạn có thể thêm các route khác ở đây
      },
      home: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          // Kiểm tra trạng thái đăng nhập
          if (isLoggedIn) {
            return AdminPage(); // Nếu đã đăng nhập, hiển thị trang Admin
          } else {
            return onboarding ? SignInPage() : OnboardingView(); // Nếu chưa đăng nhập, hiển thị trang đăng nhập hoặc onboarding
          }
        },
      ),
    );
  }
}

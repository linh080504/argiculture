import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/UI/custom_textfield.dart';
import 'package:weather/UI/home.dart';
import 'package:weather/UI/login.dart';
import 'package:weather/UI/signup.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/reset-password.png'),
              const Text('Forgot\nPassword', style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700
              ),),
              const SizedBox(
                height: 30,
              ),
                CustomTextfield(
                obscureText: false,
                hintText: 'Enter email',
                icon: Icons.alternate_email,
                  validator: (value) { // Thêm validator cho email
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty.';
                    }
                    return null;
                  },
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(context,
                      PageTransition(
                          child: const Home(),
                          type: PageTransitionType.bottomToTop));
                },
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: secondColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: const Center(
                    child: Text('Reset Password', style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0
                    ),),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(context,
                      PageTransition(
                          child:  SignUpPage(),
                          type: PageTransitionType.bottomToTop));
                },
                child: Center(
                  child: Text.rich(
                      TextSpan(
                          children: [
                            TextSpan(
                                text: 'Have an Account?',
                                style: TextStyle(
                                  color: blackColor,
                                )
                            ),
                            TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  color: secondColor,
                                )
                            ),
                          ]
                      )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/Amin/admin_page.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/Database/firebase_auth_services.dart';
import 'package:weather/UI/custom_textfield.dart';
import 'package:weather/UI/forgot_password.dart';
import 'package:weather/UI/home.dart';
import 'package:weather/UI/signup.dart';
import 'package:weather/Expert/homeExpert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather/Expert/CreateProFileExpert.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Thêm khóa Form
  String? selectedRole;

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);

      // Lưu tên người dùng vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true); // Lưu trạng thái đăng nhập
      await prefs.setString('userName', googleUser.displayName ?? 'Người dùng'); // Lưu tên

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thành công'),
        ),
      );

      // Chuyển hướng dựa trên vai trò
      await _navigateBasedOnRole();
    } catch (e) {
      print('Đăng nhập thất bại: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thất bại: $e'),
        ),
      );
    }
  }
  Future<void> _navigateBasedOnRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role == 'Admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    } else if (role == 'Expert') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>const ExpertHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  Future<User?> loginUsingEmailPassword({
    required String email,
    required String password,
    required String selectedRole,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;

      if (user != null) {
        final firestore = FirebaseFirestore.instance;

        // Sử dụng email làm document ID
        DocumentSnapshot userDoc = await firestore.collection('users').doc(email).get();

        if (userDoc.exists) {
          String roleFromFirestore = userDoc['role'] ?? '';

          // Kiểm tra vai trò
          if (roleFromFirestore != selectedRole) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Role mismatch. Please check your role.")),
            );
            return null;
          }

          // Lưu thông tin vào SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userName', userDoc['fullName'] ?? email);
          await prefs.setString('role', roleFromFirestore);

          if (roleFromFirestore == 'expert') {
            // Kiểm tra xem "profile" của expert đã tồn tại chưa
            QuerySnapshot profileSnapshot = await firestore
                .collection('users')
                .doc(email)
                .collection('profile')
                .get();

            if (profileSnapshot.docs.isEmpty) {
              // Nếu chưa có profile, chuyển đến trang tạo hồ sơ
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProfilesPage(),
                ),
              );
            } else {
              // Nếu đã có profile, chuyển đến HomeExpert
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ExpertHome()),
              );
            }
          } else if (roleFromFirestore == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user data found in Firestore.")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found for that email.")),
        );
      } else if (e.code == "wrong-password") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong password provided.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    return user;
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/signin.png'),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextfield(
                  controller: _emailController,
                  obscureText: false,
                  hintText: 'Enter Email',
                  icon: Icons.alternate_email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty.';
                    }
                    return null;
                  },
                ),
                CustomTextfield(
                  controller: _passwordController,
                  obscureText: true,
                  hintText: 'Enter Password',
                  icon: Icons.alternate_email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password cannot be empty.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue;
                    });
                  },
                  items: ['User', 'Expert', 'Admin']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(size.width, 60),
                    backgroundColor: secondColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      print('Email: $email');
                      print('Password: $password');
                      User? user = await loginUsingEmailPassword(
                        email: email,
                        password: password,
                        selectedRole: selectedRole!,
                        context: context,
                      );
                      if (user != null) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('email', email); // Lưu địa chỉ email
                        await prefs.setString('role', selectedRole ?? 'User'); // Lưu vai trò
                        // Chuyển hướng dựa trên vai trò đã chọn
                        await _navigateBasedOnRole();
                      }
                    }
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        child: const ForgotPassword(),
                        type: PageTransitionType.bottomToTop,
                      ),
                    );
                  },
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Forgot Password? ',
                            style: TextStyle(
                              color: blackColor,
                            ),
                          ),
                          TextSpan(
                            text: 'Reset Here',
                            style: TextStyle(
                              color: secondColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _signInWithGoogle,
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: secondColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Image.asset('assets/google.png'),
                        ),
                        Text(
                          'Sign In with Google',
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        child: const SignUpPage(),
                        type: PageTransitionType.bottomToTop,
                      ),
                    );
                  },
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'New to Planty? ',
                            style: TextStyle(color: blackColor),
                          ),
                          TextSpan(
                            text: 'Register',
                            style: TextStyle(color: secondColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/Database/argiculture/user.dart';
import 'package:weather/Database/firebase_auth_services.dart';
import 'package:weather/Database/toast.dart';
import 'package:weather/UI/custom_textfield.dart';
import 'package:weather/UI/home.dart';
import 'package:weather/UI/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/UI/CustomDropDow.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // Thêm controller cho re-enter password
  List<String> availableRoles = ['User', 'Expert', 'Admin'];
  String? selectedRole;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool isSigningUp = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .get();
        if (!userDoc.exists) {
          await addUserToFirestore(
              user.email!, user.displayName ?? 'Unknown', '', 'User');
        }

        _showRoleDialog(user);
      }
    } catch (e) {
      print('Đăng nhập thất bại: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thất bại: $e'),
        ),
      );
    }
  }

  Future<void> _showRoleDialog(User user) async {
    String? selectedRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn Vai Trò'),
          content: DropdownButton<String>(
            items: ['User', 'Expert', 'Admin']
                .map((role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    ))
                .toList(),
            onChanged: (value) {
              Navigator.of(context).pop(value);
            },
            hint: Text('Chọn vai trò'),
          ),
        );
      },
    );

    if (selectedRole != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .update({
        'role': selectedRole,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', selectedRole);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  // Thêm phương thức này vào lớp _SignUpPageState
  Future<void> addUserToFirestore(
      String email, String fullname, String password, String role) async {
    try {
      // Lấy tham chiếu đến Firestore
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      await users.doc(email).set({
        'fullname': fullname,
        'email': email,
        'password': password,
        'role': role,
      });

      print("User added to Firestore successfully");
    } catch (e) {
      print("Failed to add user to Firestore: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController
        .dispose(); // Dispose controller khi không cần nữa
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSigningUp = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;
      String fullname = _usernameController.text;
      String role = selectedRole ?? 'User';
      try {
        User? user = await _auth.signUpWithEmailAndPassword(email, password);

        if (user != null) {
          await addUserToFirestore(email, fullname, password, role);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('fullname', fullname);
          await prefs.setString('role', role);

          setState(() {
            isSigningUp = false;
          });

          showToast(message: "User is successfully created");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isSigningUp = false;
        });

        if (e.code == 'email-already-in-use') {
          showToast(
              message: "Email đã được đăng ký. Vui lòng sử dụng email khác.");
        } else {
          showToast(message: "Some error happened: ${e.message}");
        }
      } catch (e) {
        setState(() {
          isSigningUp = false;
        });
        showToast(message: "An unknown error occurred: $e");
      }
    }
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
                Image.asset('assets/signup.png'),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  obscureText: false,
                  hintText: 'Enter Email',
                  icon: Icons.alternate_email,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty.';
                    }
                    return null;
                  },
                ),
                CustomTextfield(
                  obscureText: false,
                  hintText: 'Enter Full name',
                  icon: Icons.person,
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'User cannot be empty.';
                    }
                    return null;
                  },
                ),
                CustomDropdown(
                  hintText: 'Select Roles',
                  icon: Icons.work,
                  items: availableRoles,
                  selectedValue: selectedRole,
                  // Assuming 'selectedRole' is a String? variable
                  onChanged: (updatedRole) {
                    setState(() {
                      selectedRole = updatedRole; // Update the selected role
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                CustomTextfield(
                  obscureText: true,
                  hintText: 'Enter Password',
                  icon: Icons.lock,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password cannot be empty.';
                    }
                    return null;
                  },
                ),
                CustomTextfield(
                  obscureText: true,
                  // Ẩn nội dung cho trường nhập lại mật khẩu
                  hintText: 'Re-enter Password',
                  // Nhập lại mật khẩu
                  icon: Icons.lock,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password.';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match.'; // Kiểm tra khớp mật khẩu
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    _signUp();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInPage()),
                    );
                  },
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      color: secondColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: const Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
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
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: _signInWithGoogle,
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                        border: Border.all(color: secondColor),
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Image.asset('assets/google.png'),
                        ),
                        Text(
                          'Sign Up with Google',
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: const SignInPage(),
                            type: PageTransitionType.bottomToTop));
                  },
                  child: Center(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: 'Have an Account? ',
                          style: TextStyle(
                            color: blackColor,
                          ),
                        ),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: secondColor,
                          ),
                        ),
                      ]),
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

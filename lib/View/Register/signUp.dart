import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lap9/View/Register/banner.dart';
import 'package:lap9/View/Register/signIn.dart';
import 'package:lap9/components/concept.dart';
import 'package:lap9/components/defaultButton.dart';
import 'package:lap9/components/defaultTextLabel.dart';
import '../../components/Navbar/Bottom_Navigation_Bar.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reenterPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ClipOval(
                    child: Image.network(
                      'https://static.vecteezy.com/system/resources/previews/011/618/136/non_2x/shopee-element-symbol-shopee-food-shopee-icon-free-vector.jpg',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.only(left: 13, right: 13),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Đăng ký',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        DefaultTextLabel(
                          text: 'Nhập Email',
                          controller: usernameController,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Email không được để trống';
                            }
                            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        DefaultTextLabel(
                          text: 'Tên',
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên';
                            }
                            if (RegExp(r'[0-9]|[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                              return 'Tên không được chứa số và kí tự đặc biệt';
                            }
                            return null;
                          },
                        ),
                        DefaultTextLabel(
                          text: 'Số điện thoại',
                          controller: phoneController,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Số điện thoại không được để trống';
                            }
                            if (!RegExp(r"^0\d{9}$").hasMatch(value)) {
                              return 'SĐT phải có 10 chữ số và bắt đầu bằng số 0';
                            }
                            return null;
                          },
                        ),

                        DefaultTextLabel(
                          text: 'Nhập mật khẩu',
                          controller: passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Mật khẩu không được để trống';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        DefaultTextLabel(
                            text: 'Nhập lại mật khẩu',
                            controller: reenterPasswordController,
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Vui lòng nhập lại mật khẩu';
                              }
                              if (value != passwordController.text) {
                                return 'Mật khẩu nhập lại không khớp';
                              }
                              return null;
                            }),
                        DefaultButton(
                          text: 'Đăng ký',
                          press: _onSignUpPressed,
                          color: Kpraimry,
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SignIn()));
                                    },
                                    child: const Text('Đăng nhập'),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Quên mật khẩu?'),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const NavBar()));
                                },
                                child: const Text('Để sau nha , xem món trước'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const banner(),
            ],
          ),
        ),
      ),
    );
  }

  void _onSignUpPressed() async {
    if (_formKey.currentState!.validate()) {
      String username = usernameController.text;
      String password = passwordController.text;
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: username, password: password);
        await _saveInfoToFirebase(userCredential.user!.uid, nameController.text, phoneController.text);
        if (userCredential.user != null) {

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text(
                  'Đăng ký thành công',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                content: const Text(
                  'Bạn có muốn đăng nhập ngay bây giờ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                backgroundColor: Colors.white,
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(
                            'Ở lại',
                            style: TextStyle(color: Colors.red[600], fontSize: 15),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(color: Colors.green[600], fontSize: 15),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = "Mật khẩu quá yếu.";
            break;
          case 'email-already-in-use':
            errorMessage = "Email đã tồn tại.";
            break;
          case 'invalid-email':
            errorMessage = "Địa chỉ email không hợp lệ.";
            break;
          default:
            errorMessage = "Đã xảy ra lỗi: ${e.message}";
            break;
        }
        print(errorMessage);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }
  Future<void> _saveInfoToFirebase(String userId, String name, String phone) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users').doc(userId).collection('userInfo');
    await users.doc(userId).set({
      'name': name,
      'phone': phone,
    }, SetOptions(merge: true));
  }
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    reenterPasswordController.dispose();
    super.dispose();
  }
}

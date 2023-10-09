import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lap9/View/Register/banner.dart';
import 'package:lap9/View/Register/signup.dart';
import 'package:lap9/components/concept.dart';
import 'package:lap9/components/defaultButton.dart';
import 'package:lap9/components/defaultTextLabel.dart';
import 'package:lap9/components/Navbar/Bottom_Navigation_Bar.dart';
import 'package:provider/provider.dart';

import '../../Controller/Auth_model.dart';
import '../Profile/forgotPassword.dart';
class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                  child: Container(
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
                          width: 200,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đăng nhập',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900
                                ),
                              ),
                            ],
                          ),
                        ),
                        DefaultTextLabel(
                          text: 'Email',
                          controller: emailController,
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
                          text: 'Mật khẩu',
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
                        DefaultButton(
                          text: 'Đăng nhập',
                          press: () async {
                            String email = emailController.text;
                            String password = passwordController.text;

                            var authModel = Provider.of<AuthModel>(context, listen: false);
                            try {
                              await authModel.signIn(email, password);

                              if (authModel.user != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("Đăng nhập thành công!",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    backgroundColor: Colors.green[400],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                Future.delayed(const Duration(seconds: 2), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const NavBar()),
                                  );
                                });
                              }
                            } on FirebaseAuthException catch (e) {
                              String errorMessage;
                              switch (e.code) {
                                case 'wrong-password':
                                case 'user-not-found':
                                  errorMessage = "Tài khoản hoặc Mật khẩu không chính xác.";
                                  break;
                                case 'invalid-email':
                                  errorMessage = "Địa chỉ email không hợp lệ.";
                                  break;
                                default:
                                  errorMessage = "Đã xảy ra lỗi: ${e.message}";
                                  break;
                              }

                              print(errorMessage);  // Log ra lỗi để kiểm tra

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
                                ),
                              );
                            }

                          },
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
                                          MaterialPageRoute(builder: (context) => SignUp())
                                      );
                                    },
                                    child: const Text('Đăng ký'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ForgotPassword())
                                      );
                                    },
                                    child: const Text('Quên mật khẩu?'),
                                  ),
                                ],
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const NavBar())
                                  );
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

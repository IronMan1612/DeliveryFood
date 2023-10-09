import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'forgotPassword.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: Colors.orange,
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                const Text("Nhập mật khẩu hiện tại"),
                const SizedBox(height: 5),
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu hiện tại';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                  decoration:  InputDecoration(
                    hintText: "Mật khẩu hiện tại",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text("Nhập mật khẩu mới"),
                const SizedBox(height: 5),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Mật khẩu mới",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: confirmNewPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Mật khẩu nhập lại không khớp';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Xác nhận mật khẩu mới",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _onChangePasswordPressed,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.orange, // Màu văn bản
                    textStyle: const TextStyle(
                      fontSize: 18,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Center(
                    child: Text(
                      'Lưu',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ForgotPassword()),
                      );
                    },
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
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

  void _onChangePasswordPressed() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Lấy user hiện tại
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Xác minh mật khẩu hiện tại với Firebase
          final currentPassword = currentPasswordController.text;
          final credential = EmailAuthProvider.credential(
              email: user.email!, password: currentPassword);

          // Được sử dụng để kiểm tra xem mật khẩu hiện tại có đúng không
          await user.reauthenticateWithCredential(credential);

          // Cập nhật mật khẩu mới
          final newPassword = newPasswordController.text;
          await user.updatePassword(newPassword);


        // Làm mới trạng thái và làm trống các ô nhập
          setState(() {
            currentPasswordController.clear();
            newPasswordController.clear();
            confirmNewPasswordController.clear();
          });

          // Hiển thị SnackBar với màu xanh và chữ trắng
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Đổi mật khẩuthành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.green,  // Sửa màu ở đây
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              duration: const Duration(seconds: 1),
            ),
          );

        }
      } catch (e) {
        String errorMessage;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'wrong-password':
              errorMessage = "Mật khẩu hiện tại không đúng.";
              break;
            case 'weak-password':
              errorMessage = "Mật khẩu mới quá yếu.";
              break;
            default:
              errorMessage = "Đã xảy ra lỗi: ${e.message}";
              break;
          }
        } else {
          errorMessage = "Đã xảy ra lỗi không xác định.";
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


  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }
}

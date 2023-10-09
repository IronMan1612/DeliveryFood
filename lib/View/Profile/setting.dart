import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lap9/View/Profile/user_profile_details.dart';
import 'DeleteAccount.dart';
import 'changePassword.dart';
import 'customAction.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
        backgroundColor: Colors.orange,
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cài đặt tài khoản", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              action(
                icon: Icons.person,
                text: "Thông tin & liên hệ",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UserProfileDetails()),
                  );
                },
              ),
              action(
                icon: Icons.lock,
                text: "Đổi mật khẩu",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ChangePassword()),
                  );
                },
              ),
              SizedBox(height: 20.0),
              Text("Cài đặt ứng dụng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              action(
                icon: Icons.language,
                text: "Đổi ngôn ngữ",
                onTap: () {
                  // Chuyển trang tới đổi ngôn ngữ
                },
              ),
              action(
                icon: Icons.notifications,
                text: "Cài đặt thông báo",
                onTap: () {
                },
              ),
              SizedBox(height: 20.0),
              Text("Hỗ trợ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              action(
                icon: Icons.delete,
                text: "Yêu cầu xoá tài khoản",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeleteAccount()),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}

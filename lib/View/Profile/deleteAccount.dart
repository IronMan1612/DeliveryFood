import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lap9/View/Register/signIn.dart';

class DeleteAccount extends StatefulWidget {
  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Yêu cầu xoá tài khoản'),
      ),
      body: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.warning,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chúng tôi rất tiếc khi bạn muốn rời đi. Nếu tạm thời bạn không muốn dùng tài khoản này, bạn có thể Đăng xuất và Đăng nhập lại bất cú khi nào. Sau khi xoá tài khoản, bạn không thể:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 25),
                  Text("- Đăng nhập vào Ứng dụng bằng tài khoản hiện tại"),
                  SizedBox(height: 10),
                  Text("- Tận hưởng các lợi ích, ưu đãi hiện có: voucher,món ăn."),
                  SizedBox(height: 10),
                  Text("- Truy cập vào lịch sử đơn hàng, thông báo đã nhận trước đó"),
                  SizedBox(height: 10),
                  Text("- Truy cập vào thông tin thanh toán và tài khoản ngân hàng đã lưu"),
                  SizedBox(height: 25),
                  Text("Cám ơn bạn đã sử dụng ứng dụng trong thời gian qua. Chúc bạn có một ngày tốt lành!",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onDeleteAccountPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Container(
                width: double.infinity,
                child: const Center(
                  child: Text('Tiếp tục'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDeleteAccountPressed() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Xoá tài khoản',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: const Text(
            'Bạn muốn xoá tài khoản này?',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    child: const Text('Đồng ý', style: TextStyle(color: Colors.orange)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // Hiển thị thông báo xoá tài khoản thành công
                      _showSuccessDialog();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String email = FirebaseAuth.instance.currentUser!.email!;
        String uid = FirebaseAuth.instance.currentUser!.uid;

        // Lưu ID người dùng vào Firestore
        FirebaseFirestore.instance.collection('delete_users').doc(uid).set({
          'userId': uid,
          'email': email,
          'requestDate': Timestamp.now(), // thêm thời gian yêu cầu
        });

        return AlertDialog(
          title: const Center(
            child: Text(
              "Thành công!",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              children: <TextSpan>[
                const TextSpan(text: "Chúng tôi đã nhận được yêu cầu xoá tài khoản "),
                TextSpan(
                  text: email,
                  style: const TextStyle(color: Colors.orange),
                ),
                const TextSpan(text: " . Yêu cầu sẽ được xử lý từ 1 - 3 ngày làm việc"),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              width: double.infinity,
              child: TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

}

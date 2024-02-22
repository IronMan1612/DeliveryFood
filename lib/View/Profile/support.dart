import 'package:flutter/material.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ'),
        backgroundColor: Colors.orange, // màu cam cho AppBar
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thông tin liên hệ:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Điện thoại: 0585772826'),
              const SizedBox(height: 5),
              const Text('Email: lethanhhung16122001@gmail.com'),

              const SizedBox(height: 20),
              const Text('Địa chỉ:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text('Đà Nẵng'),

              const SizedBox(height: 20),
              const Text('Thời gian làm việc:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Thứ Hai - Thứ Sáu: 6:00 - 23:00'),
              const SizedBox(height: 5),
              const Text('Thứ Bảy - Chủ Nhật: Đóng cửa'),
              const Spacer(), // Đẩy nút xuống dưới cùng của màn hình
              SizedBox(
                width: double.infinity, // Chiều rộng bằng với màn hình
                child: ElevatedButton(
                  onPressed: () {
                    // Đánh giá ứng dụng
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.orange, // Màu văn bản
                  ),
                  child: const Text('Đánh giá ứng dụng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

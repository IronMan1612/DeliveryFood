import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Về chúng tôi'),
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Box Decoration với ảnh từ assets
              Center(
                child: Container(
                  width: 500,  // Thu nhỏ chiều rộng
                  height: 130,  // Thu nhỏ chiều cao
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,  // Sử dụng BoxFit.contain
                      image: AssetImage('assets/ShopeeFood.png'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Khoảng trống giữa ảnh và văn bản
              const Text('Ứng dụng đặt hàng trực tuyến ngay trên điện thoại ,máy tính. Mọi lúc , mọi nơi , chúng tôi sẽ đáp ứng nhu cầu của bạn một cách nhanh chóng chỉ với vài bước đơn giản', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const Text('Thông tin sở hữu: Lê Thành Hưng', style: TextStyle(fontSize: 16)),
              const Text('Điện thoại: 0585772826', style: TextStyle(fontSize: 16)),
              const Text('Địa chỉ: Đà Nẵng', style: TextStyle(fontSize: 16)),
              const Text('Email: lethanhhung16122001@gmail.com', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 25), // Khoảng trống giữa ảnh và văn bản
              Container(
                width: 330,  // Thu nhỏ chiều rộng
                height: 110,  // Thu nhỏ chiều cao
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,  // Sử dụng BoxFit.contain
                    image: AssetImage('assets/ShopeeFood1.png'),
                  ),
                ),
              ),

              const SizedBox(height: 25), // Khoảng trống giữa ảnh và văn bản
              const Spacer(), // Đẩy nút xuống dưới cùng của màn hình
              Container(
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

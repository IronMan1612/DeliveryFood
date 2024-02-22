import 'package:admin_delivery_food/Services/Firebase_Service.dart';
import 'package:flutter/material.dart';

import '../../Model/Order.dart';

class OverViewScreen extends StatefulWidget {
  const OverViewScreen({super.key});

  @override
  _OverViewScreenState createState() => _OverViewScreenState();
}

class _OverViewScreenState extends State<OverViewScreen> {
  late Future<List<FoodOrder>> orders;

  @override
  void initState() {
    super.initState();
    orders = FirebaseService().getAllOrders();
  }


  Future<void> _refreshData() async {
    setState(() {
      orders = FirebaseService().getAllOrders();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng Quan'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<List<FoodOrder>>(
            future: orders,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.fastfood, size: 50, color: Colors.orange),
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Center(
                  child: Text('Lỗi: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Không có dữ liệu đơn hàng'),
                );
              } else {
                List<FoodOrder> orders = snapshot.data!;

                int totalOrders = orders.length;

                int completedOrders = orders.where((order) => order.status == 'Hoàn thành').length;
                int pendingOrders = orders.where((order) => ['Chờ xác nhận', 'Đang giao hàng'].contains(order.status)).length;
                int canceledOrders = orders.where((order) => order.status == 'Đã huỷ').length;

                double totalRevenue = 0;
                double totalDiscount = 0;
                double expectedRevenue = 0;
                double total = 0;


                orders.forEach((order) {
                  if (['Hoàn thành', 'Chờ xác nhận', 'Đang giao hàng'].contains(order.status)) {
                    totalRevenue += order.totalPrice;
                    totalDiscount += order.discount;
                    expectedRevenue += order.totalWithDiscount;
                  }

                  if (['Hoàn thành'].contains(order.status)) {
                    total += order.totalWithDiscount;
                  }
                });

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            color: Colors.grey,
                            padding: const EdgeInsets.all(8),
                            child: _buildInfoColumn('Tổng đơn hàng', totalOrders, imagePath: 'assets/all.png'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              color: Colors.lightGreenAccent,
                              padding: const EdgeInsets.all(8),
                              child: _buildInfoColumn('Hoàn thành', completedOrders, imagePath: 'assets/checked.png'),
                            ),
                            Container(
                              color: Colors.lightBlueAccent,
                              padding: const EdgeInsets.all(8),
                              child: _buildInfoColumn('Chờ xử lý', pendingOrders, imagePath: 'assets/clipboard.png'),
                            ),
                            Container(
                              color: Colors.redAccent,
                              padding: const EdgeInsets.all(8),
                              child: _buildInfoColumn('Đã huỷ', canceledOrders, imagePath: 'assets/cancel.png'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            _buildInfoRow('Doanh thu gốc', totalRevenue, imagePath: 'assets/money-bag.png'),
                            const Divider(color: Colors.grey),
                            _buildInfoRow('Giảm giá từ voucher', -totalDiscount, imagePath: 'assets/coupon.png'),
                            const Divider(color: Colors.grey),
                            _buildInfoRow('Doanh thu dự kiến', expectedRevenue, imagePath: 'assets/money.png'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/budgeting.png',
                                height: 35,
                                width: 35,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Doanh thu thực nhận: ',
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                              Text(
                                '${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                                style: const TextStyle(fontSize: 18, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, dynamic value, {String? imagePath}) {
    return Column(
      children: [
        if (imagePath != null)
          Image.asset(
            imagePath,
            height: 35,
            width: 35,
            fit: BoxFit.contain,
          ),
        if (imagePath != null) const SizedBox(height: 5), // Add some space if there's an image
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        Text(
          '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đơn',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, dynamic value, {String? imagePath}) {
    return Row(
      children: [
        if (imagePath != null)
          Image.asset(
            imagePath,
            height: 35,
            width: 35,
            fit: BoxFit.contain,
          ),
        if (imagePath != null) const SizedBox(width: 8), // Add some space if there's an image
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }


}

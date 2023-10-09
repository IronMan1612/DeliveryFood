import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../View/Order/orderDetail.dart';
class OrderListItem extends StatelessWidget {
  final QueryDocumentSnapshot order;

  OrderListItem({required this.order});


  // Helper function to create padded order ID
  String formatOrderId(String id) {
    return id.padLeft(5, '0');
  }

  String formatOrderDate(DateTime orderDate) {
    DateTime currentDate = DateTime.now();

    // Định dạng thời gian
    String formattedTime =
        '${orderDate.hour.toString().padLeft(2, '0')}:${orderDate.minute.toString().padLeft(2, '0')}';

    // Kiểm tra nếu ngày đặt hàng là hôm nay
    if (currentDate.year == orderDate.year &&
        currentDate.month == orderDate.month &&
        currentDate.day == orderDate.day) {
      return 'Hôm nay | $formattedTime';
    }
    // Kiểm tra nếu ngày đặt hàng là hôm qua
    else if (currentDate.year == orderDate.year &&
        currentDate.month == orderDate.month &&
        currentDate.day == orderDate.day + 1) {
      return 'Hôm qua | $formattedTime';
    }
    // Ngày đặt hàng thông thường
    else {
      return '${orderDate.day.toString().padLeft(2, '0')}/${orderDate.month.toString().padLeft(2, '0')}/${orderDate.year} | $formattedTime';
    }
  }

  @override
  Widget build(BuildContext context) {

    var address = order.get('address');
    var orderDate = DateTime.parse(order.get('orderDate')).toLocal();
    String formattedDate = formatOrderDate(orderDate);

    var orderId = formatOrderId(order.get('id').toString()); // Format the order ID

    var orderItemsMap = order.get('orderItems') as Map<String, dynamic>;





    // Tính tổng số lượng của tất cả các mục
    var totalItems = orderItemsMap.values.fold<int>(0, (prev, itemData) => prev + (int.tryParse((itemData['quantity'] ?? '0').toString()) ?? 0));



    var totalPrice = order.get('totalPrice');
    var status = order.get('status');
    //Màu ứng vs các trạng thái
    Color getStatusColor(String status) {
      switch (status) {
        case 'Đã huỷ':
          return Colors.red;
        case 'Chờ xác nhận':
          return Colors.black;
        case 'Đang giao hàng':
          return Colors.orange;
        case 'Hoàn thành':
          return Colors.green;
        default:
          return Colors.blue;  // màu mặc định
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Đồ ăn #$orderId", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text(formattedDate.toString()),
              ],
            ),
            const Divider(color: Colors.black),
            Row(
              children: [
                Image.asset('assets/fastfood.png', width: 100, height: 100, fit: BoxFit.cover),
                // Replace with your image URL
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),  // Add space before the first Text
                      const Text(
                        "Đơn hàng Đồ Ăn",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,  // Bold text
                            fontSize: 20,  // Increased font size
                            color: Colors.black  // Black color
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Địa chỉ: ${address['fullAddress']}",
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ - $totalItems món - Tiền mặt",
                        style: const TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

              ],
            ),
            const Divider(color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: TextStyle(color: getStatusColor(status)),
                ),
                Row(
                  children: [
                    if (status == 'Hoàn thành') ...[
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text("Đánh giá"),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (status == 'Đã huỷ' || status == 'Hoàn thành')
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text("Đặt lại"),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
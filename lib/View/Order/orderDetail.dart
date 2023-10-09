import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Model/food_item.dart';
import '../../Services/Firebase_Service.dart';
import '../../components/Navbar/Bottom_Navigation_Bar.dart';

class OrderDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot order;

  OrderDetailScreen({required this.order});

  Future<List<FoodItem>> _getItems() async {
    var itemsMap = order.get('orderItems') as Map<String, dynamic>;
    List<FoodItem> items = [];
    for (var key in itemsMap.keys) {
      var foodItem = await FirebaseService().getFoodItemById(key);
      if (foodItem != null) {
        var itemData = itemsMap[key];
        foodItem.quantity = itemData['quantity'];
        foodItem.note = itemData['note'];
        items.add(foodItem);
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    var address = order.get('address');
    double totalPrice = order.get('totalPrice');
    double discount = order.get('discount');
    double totalWithDiscount = order.get('totalWithDiscount');
    int totalItems = order.get('totalItems') ?? 0;
    var status = order.get('status');
    var orderDate = DateTime.parse(order.get('orderDate')).toLocal();

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
          return Colors.blue; // màu mặc định
      }
    }
    Widget _loadImage(String imagePath) {
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          width: 60,
          height: 90,
          fit: BoxFit.cover,
        );
      } else {
        return Image.asset(
          imagePath,
          width: 60,
          height: 90,
          fit: BoxFit.cover,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        backgroundColor: Colors.orange,
      ),
      body: ListView(padding: const EdgeInsets.all(16.0), children: [
        // Phần địa chỉ
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    Expanded(
                        child: Text("${address['fullAddress']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20.0,
                            )))
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.black),
                    Text("${address['name']}"),
                    const SizedBox(width: 30),
                    const Icon(Icons.call, color: Colors.green),
                    Text("${address['phoneNumber']}")
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: (address['note'] != null &&
                              address['note'].isNotEmpty)
                          ? Text("Ghi chú: ${address['note']}")
                          : const SizedBox
                              .shrink(), // không có ghi chú sẽ không hiện dòng này
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15.0),

        // Phần danh sách món
        Card(

          child: FutureBuilder<List<FoodItem>>(
            future: _getItems(),
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
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có dữ liệu'));
              } else {
                List<FoodItem> items = snapshot.data!;
                return Column(
                  children: List.generate(items.length, (index) {
                    var item = items[index];
                    return ListTile(
                      onTap: () {},
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _loadImage(item.imagePath),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          Text(
                              "Giá: ${item.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ",
                              style: const TextStyle(color: Colors.orange)),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          item.note != null && item.note!.isNotEmpty
                              ? Text("Ghi chú: ${item.note}",
                                  style: const TextStyle(color: Colors.black))
                              : const SizedBox.shrink(),
                          Text("Số lượng: ${item.quantity}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    );
                  }),
                );
              }
            },
          ),
        ),

        const SizedBox(height: 16.0),

        // Phần thông tin tổng kết
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tổng cộng ($totalItems món)"),
                    Text(
                        "${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ"),
                  ],
                ),
                const SizedBox(height: 3),
                const Divider(),
                const SizedBox(height: 3),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Phí giao hàng"),
                    Text("Miễn phí"),
                  ],
                ),
                const SizedBox(height: 3),
                const Divider(),
                const SizedBox(height: 3),
                ...(discount == 0
                    ? [] // Danh sách rỗng nếu giá trị giảm giá là 0
                    : [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Mã khuyến mãi"),
                      Text(
                          "-${discount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ"),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Divider(),
                ]),

                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Thanh toán",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        Text(
                            "${totalWithDiscount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ",
                            style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 7),
                        const Text("Đã bao gồm thuế")
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15.0),
        // Thông tin tổng kết
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Chi tiết đơn hàng",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                // Mã đơn hàng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Mã đơn hàng"),
                    Row(
                      children: [
                        Text(order.id),
                        TextButton(
                          onPressed: () {
                            // Thực hiện sao chép id đơn hàng
                            Clipboard.setData(ClipboardData(text: order.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép mã đơn hàng!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text(
                            "Sao chép",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
// Thời gian đặt hàng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Thời gian đặt hàng"),
                    Text(
                      formatOrderDate(orderDate), // Hàm này sẽ trả về chuỗi ngày đã định dạng
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                // Thanh toán
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Thanh toán"),
                    Text("Tiền mặt"),
                  ],
                ),
                const SizedBox(height: 12.0),
                // Trạng thái
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Trạng thái"),
                    Text("$status",
                        style: TextStyle(color: getStatusColor(status), fontSize: 20)),
                  ],
                ),

                if (status == 'Chờ xác nhận') ...[
                  const SizedBox(height: 10.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Hiện hộp thoại xác nhận
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Center(
                                child: Text('Huỷ đơn hàng',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 23))),
                            content: const Text(
                              'Bạn có muốn huỷ đơn hàng không?',
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              Column(
                                children: [
                                  //const Divider(color: Colors.black54),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Đóng hộp thoại
                                          },
                                          child: const Text('Không'),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                            await FirebaseService()
                                                .updateOrderStatus(
                                                order.id, 'Đã huỷ');
                                            // Thông báo huỷ đơn thành công
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  "Huỷ đơn thành công!",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                      FontWeight.w600),
                                                ),
                                                backgroundColor:
                                                Colors.green[400],
                                                behavior: SnackBarBehavior
                                                    .floating,
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      24),
                                                ),
                                                duration: const Duration(
                                                    seconds: 1),
                                              ),
                                            );
                                            // chuyển về list order
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const NavBar(
                                                      initialPage: 2)),
                                              // 2 là index của OrderListScreen
                                                  (Route<dynamic> route) =>
                                              false, // Xóa tất cả các màn hình trước đó
                                            );
                                          },
                                          child: const Text('Có',
                                              style: TextStyle(
                                                  color: Colors.red)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                      child: const Text("Huỷ đơn",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],

                if (status == 'Hoàn thành') ...[
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                        child: const Text("Đánh Giá"),
                      ),
                      const SizedBox(width: 20.0),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                        child: const Text("Đặt lại"),
                      ),
                    ],
                  ),
                ],

                if (status == 'Đã huỷ') ...[
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                        child: const Text("Đặt lại"),
                      ),
                    ],
                  ),
                ],

              ],
            ),
          ),
        ),
      ]),
    );
  }
}

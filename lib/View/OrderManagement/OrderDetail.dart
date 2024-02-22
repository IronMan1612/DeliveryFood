import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Model/food_item.dart';
import '../../Services/Firebase_Service.dart';

class OrderDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}


class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String selectedStatus;
  late Future<List<FoodItem>> items;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.get('status');
    items = _getItems();
  }

  Future<List<FoodItem>> _getItems() async {
    var itemsMap = widget.order.get('orderItems') as Map<String, dynamic>;
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

  Stream<QuerySnapshot> getOrders(List<String> statuses) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', whereIn: statuses)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }


  Widget _loadImage(String imagePath) {
    Widget imageWidget;
    if (imagePath.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        placeholder: (context, url) => Container(
          width: 60,
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        width: 60,
        height: 90,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
        width: 60,
        height: 90,
        fit: BoxFit.cover,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        width: 60,
        color: Colors.white,
        child: imageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var order = widget.order;
    var address = order.get('address');
    double totalPrice = order.get('totalPrice').toDouble();
    double discount = order.get('discount').toDouble();
    double totalWithDiscount = order.get('totalWithDiscount').toDouble();
    int totalItems = order.get('totalItems') ?? 0;
    var status = order.get('status');
    var orderDate = DateTime.parse(order.get('orderDate')).toLocal();
    var voucherId = order.get('voucherId');

    String formatOrderDate(DateTime orderDate) {
      DateTime currentDate = DateTime.now();

      // Format thời gian
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("ID voucher: $voucherId",
                                    style: const TextStyle(color: Colors.red)),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    "-${discount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ"),
                              ],
                            ),
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
                      formatOrderDate(
                          orderDate), // Hàm này sẽ trả về chuỗi ngày đã định dạng
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
                    Text(selectedStatus,
                        style: TextStyle(
                            color: getStatusColor(selectedStatus), fontSize: 20)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Cập nhật trạng thái"),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: <String>[
                        'Đã huỷ',
                        'Chờ xác nhận',
                        'Đang giao hàng',
                        'Hoàn thành',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        // Cập nhật trạng thái khi người dùng chọn
                        if (newValue != null) {
                          try {
                            await FirebaseService().updateOrderStatus(order.id, newValue);
                            setState(() {
                              selectedStatus = newValue; // Cập nhật selectedStatus
                              status = newValue; // Cập nhật status
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã cập nhật trạng thái đơn hàng thành công!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi khi cập nhật trạng thái đơn hàng: $error'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ]),
    );
  }
}

import 'Address.dart';
import 'food_item.dart';
class FoodOrder {
  final String id;
  final String userId;
  final Map<FoodItem, int> items;
  final Address address;
  final double totalPrice;
  final int totalItems; // tổng số món
  final String? voucherId;        // id voucher
  final double discount;          // Giá trị giảm giá
  final double totalWithDiscount; // Tổng sau khi đã áp dụng giảm giá
  final DateTime orderDate;
  String status;

  FoodOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.totalPrice,
    required this.totalItems,
    this.voucherId,
    required this.discount,
    required this.totalWithDiscount,
    required this.orderDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> itemsMap = {};

    items.forEach((key, value) {
      itemsMap[key.id] = {
        'name': key.name,       // Tên món
        'note': key.note,       // Ghi chú
        'price': key.price,     // Giá
        'imagePath': key.imagePath,  // Đường dẫn ảnh
        'quantity': value      // Số lượng
      };
    });

    return {
      'id': id,
      'userId': userId,
      'orderItems': itemsMap,
      'address': address.toMap(),
      'totalPrice': totalPrice,
      'totalItems': totalItems,
      'voucherId': voucherId,
      'discount': discount,
      'totalWithDiscount': totalWithDiscount,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }
}

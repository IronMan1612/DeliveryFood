import 'package:flutter/foundation.dart';
import '../../Model/food_item.dart';
import '../../Services/Firebase_Service.dart'; // Đảm bảo bạn đã import FirebaseService

class Cart extends ChangeNotifier {
  Map<FoodItem, int> items = {};
  final FirebaseService _firebaseService = FirebaseService();
  List<String> _unavailableFoods = [];

  List<String> get unavailableFoods => _unavailableFoods;

  int get totalItems {
    return items.values.fold(0, (previousValue, quantity) => previousValue + quantity);
  }

  void addToCart(FoodItem food) {
    if (items.containsKey(food)) {
      items[food] = items[food]! + 1;
    } else {
      items[food] = 1;
    }
    saveCart();  // Tự động lưu sau khi thêm
    notifyListeners();
  }

  void removeFromCart(FoodItem food) {
    if (items.containsKey(food)) {
      if (items[food]! > 1) {
        items[food] = items[food]! - 1;
      } else {
        items.remove(food);
      }
    }
    saveCart();  // Tự động lưu sau khi xoá
    notifyListeners();
  }
  void updateNoteForFood(FoodItem food, String newNote) {
    if (items.containsKey(food)) {
      var existingFoodItem = items.keys.firstWhere((item) => item.id == food.id);
      if (existingFoodItem != null) {
        // Cập nhật thuộc tính 'note' cho đối tượng 'FoodItem' trong giỏ hàng
        existingFoodItem.note = newNote;
      }
    }
    saveCart(); // Lưu giỏ hàng sau khi cập nhật
    notifyListeners();
    // Cập nhật giỏ hàng nếu bạn lưu trữ nó trong database hoặc tương tự

  }
  int getTotalItems() {
    return items.values.fold(0, (previous, current) => previous + current);
  }


  Future<void> saveCart() async {
    print("saveCart is being called.");
    await _firebaseService.saveCartToFirestore(items);
    notifyListeners(); // Thông báo khi hoàn tất việc lưu giỏ hàng
  }

  Future<void> loadCart() async {         // được gọi trong Cart_Screen để tải lại giỏ hàng đã lưu
    print("loadCart is being called.");
    var result = await _firebaseService.loadCartFromFirestore();
    items = result;
   // _unavailableFoods = result.second;
   // print("$_unavailableFoods is being called.");
// Bạn có thể sử dụng `unavailableFoods` ở đây để thông báo cho người dùng.

    notifyListeners(); // Thông báo khi hoàn tất việc tải giỏ hàng
  }
// Xoá giỏ hàng sau khi đặt hàng
  void clearCart() {
    items.clear();
    notifyListeners();
  }
  /*Future<void> loadAddresses() async {
    print("loadAddress is being called.");
    items = (await _firebaseService.loadAddressesFromFirestore()) as Map<FoodItem, int>;
    notifyListeners(); // Thông báo khi hoàn tất việc tải địa chỉ
  }

   */
}

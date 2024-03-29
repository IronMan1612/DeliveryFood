import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:DeliveryFood/Model/food_category.dart';
import 'package:DeliveryFood/Model/food_item.dart';

import '../Data/banner_list_data.dart';
import '../Data/category_list_data.dart';
import '../Data/food_list_data.dart';
import '../Data/voucher_list_data.dart';
import '../Model/Address.dart';
import '../Model/Order.dart';
import '../Model/Voucher.dart';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


//1 Món ăn


  //1.1

  // upload data Food có sẵn lên web
  Future<void> uploadFoodsData() async {
    for (var food in allFoods) {
      await setFood(food);
    }
  }


  //1.2

  // Thêm mới hoặc update  món ăn nếu đã tồn tại
  Future<void> setFood(FoodItem food) async {
    await _firestore
        .collection('foods')
        .doc(food.id)
        .set(food.toMap(), SetOptions(merge: true));
  }


  //1.3

  // Lấy tất cả dữ liệu món ăn từ Firebase
  Future<List<FoodItem>> getAllFoods() async {
    List<FoodItem> foods = [];
    QuerySnapshot snapshot = await _firestore.collection('foods').get();

    for (var doc in snapshot.docs) {
      var foodData = doc.data()! as Map<String, dynamic>;
      var foodItem = FoodItem.fromMap({
        ...foodData,
        'id': doc.id,
      });
      foods.add(foodItem);
    }

    return foods;
  }

  //2 Danh mục

  //2.1

  //Updata Category có sẵn data lên web
  Future<void> uploadCategoriesData() async {
    for (var category in categories) {
      await setCategory(category);
    }
  }

  //2.2

  // lấy categery từ firebase
  Future<List<FoodCategory>> fetchCategoriesData() async {
    List<FoodCategory> categories = [];
    QuerySnapshot snapshot = await _firestore.collection('categories').get();

    for (var doc in snapshot.docs) {
      categories.add(FoodCategory.fromMap(doc.data() as Map<String, dynamic>));
    }
    return categories;
  }


  //2.3

  // Thêm mới hoặc update Danh mục nếu đã tồn tại
  Future<void> setCategory(FoodCategory category) async {
    await _firestore.collection('categories').doc(category.id).set({
      'id': category.id,
      'name': category.name,
      'imagePath': category.imagePath,
      'foods': category.foods.toList(),
    }, SetOptions(merge: true));
  }

  //3 Banner

  //3.1

 // check banner đã tồn tại hay chưa
  Future<bool> isBannerExist(String bannerPath) async {
    final bannerSnapshot = await FirebaseFirestore.instance.collection('banners').doc(bannerPath).get();

    return bannerSnapshot.exists;
  }
// Upload banner có sẵn và check đã tồn tại hay chưa
  Future<void> uploadBannersData() async {
    for (var banner in banners) {
      if (!await isBannerExist(banner)) {
        await setBanner(banner);
      }
    }
  }

  //3.2

  // Thêm mới hoặc update nếu đã tồn tại
  Future<void> setBanner(String banner) async {
    await _firestore.collection('banners').doc(banner).set({
      'imagePath': banner,
    });
  }

// Lấy data Food theo cùng ID để tăng số lượng món lên thay vì tạo 1 món y hệt trong giỏ
  Future<FoodItem?> getFoodItemById(String foodId) async {
    DocumentSnapshot doc =
        await _firestore.collection('foods').doc(foodId).get();
    if (doc.exists) {
      return FoodItem.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }


  //4 Giỏ hàng

  //4.1

  // Tự động lưu giỏ khi tăng/giảm + điền ghi chú
  Future<void> saveCartToFirestore(Map<FoodItem, int> items) async {
    print("saveCartToFirestore is being called.");

    final currentUser = FirebaseAuth.instance.currentUser;
    print("Current User UID: ${currentUser?.uid}");

    if (currentUser != null) {
      // Chuyển đổi giỏ hàng thành một định dạng có thể lưu trữ trên Firestore
      Map<String, dynamic> cartData = {};
      items.forEach((foodItem, quantity) {
        cartData[foodItem.id] = {
          'item': foodItem.toMap(), // Lưu trữ toàn bộ thông tin của FoodItem
          'quantity': quantity
        };
      });

      try {
        await _firestore.collection('carts').doc(currentUser.uid).set({'items': cartData});
        print("Cart Data: $cartData");
      } catch (error) {
        print("Error saving cart to Firestore: $error");
      }
    }
  }

  //4.2

  // Tải lên giỏ hàng đã lưu
  Future<Map<FoodItem, int>> loadCartFromFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot snapshot = await _firestore.collection('carts').doc(currentUser.uid).get();
      if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
        Map<String, dynamic> cartData = (snapshot.data() as Map<String, dynamic>)['items'] as Map<String, dynamic>;
        Map<FoodItem, int> items = {};
        for (String foodId in cartData.keys) {
          var foodData = cartData[foodId]['item'] as Map<String, dynamic>;
          FoodItem foodItem = FoodItem.fromMap(foodData);
          items[foodItem] = cartData[foodId]['quantity'];
        }
        return items;
      }
    }
    return {};
  }

  //4.3

  //Xoá giỏ hàng ( dùng sau khi đặt hàng thành công)
  Future<void> clearUserCart(String userId) async {
    await _firestore.collection('carts').doc(userId).delete();
  }


  //5 Địa chỉ

  // 5.1. Thêm địa chỉ mới
  Future<void> addAddressToFirestore(Address address) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Tạo ID tự động
      final String newAddressId = _firestore.collection('users').doc(currentUser.uid).collection('addresses').doc().id;
      // Tạo một đối tượng Address mới với ID vừa tạo
      Address newAddress = Address(
        id: newAddressId,
        name: address.name,
        phoneNumber: address.phoneNumber,
        fullAddress: address.fullAddress,
        note: address.note,
      );
      await _firestore.collection('users').doc(currentUser.uid).collection('addresses').doc(newAddressId).set(newAddress.toMap());
    }
  }


  // 5.2. Tải tất cả địa chỉ của một người dùng
  Future<List<Address>> loadAddressesFromFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    List<Address> addresses = [];

    if (currentUser != null) {
      QuerySnapshot querySnapshot = await _firestore.collection('users').doc(currentUser.uid).collection('addresses').get();
      for (var doc in querySnapshot.docs) {
        addresses.add(Address.fromMap(doc.data() as Map<String, dynamic>));
      }
    }

    return addresses;
  }

  // 5.3. Cập nhật một địa chỉ cụ thể
  Future<void> updateAddressInFirestore(String addressId, Address newAddress) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).collection('addresses').doc(addressId).set(newAddress.toMap());
    }
  }

  // 5.4. Xóa một địa chỉ cụ thể
  Future<void> deleteAddressFromFirestore(String addressId) async {
    if (addressId.isEmpty) {
      print("Error: Address ID is empty!");  // Dùng để gỡ lỗi
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).collection('addresses').doc(addressId).delete();
    }
  }


  //6 Đơn hàng

  //6.1

  // Tạo collection metadata để lưu tự động lưu ID đơn hàng tăng dần cho đẹp ( thay vì để FireBase tự gán)
  Future<void> initializeOrderCounter() async {
    DocumentReference orderCounterRef = _firestore.collection('metadata').doc('orderCounter');

    // Kiểm tra nếu document tồn tại
    DocumentSnapshot orderCounterSnapshot = await orderCounterRef.get();

    if (!orderCounterSnapshot.exists) {
      // Nếu chưa, tạo document với giá trị ban đầu
      await orderCounterRef.set({'currentId': 0});
    }
  }

  //6.2

  // Hàm tự động tăng id đơn hàng thêm 1 sau mỗi đơn
  // Định dạng tối thiểu 5 số trên đơn hàng ( nếu đơn hàng 1 sẽ hiển thị 00001)
  Future<String> getNewOrderId() async {
    DocumentReference orderCounterRef = _firestore.collection('metadata').doc('orderCounter');
    return _firestore.runTransaction<String>((transaction) async {
      DocumentSnapshot orderCounterSnapshot = await transaction.get(orderCounterRef);

      if (!orderCounterSnapshot.exists) {
        // Nếu không tồn tại, khởi tạo nó
        await initializeOrderCounter();
        return "00001"; // Giá trị mặc định cho đơn hàng đầu tiên
      }

      int newId = orderCounterSnapshot.get('currentId') + 1;
      transaction.update(orderCounterRef, {'currentId': newId});
      return newId.toString().padLeft(5, '0');
    });
  }


  //6.3

  // Lưu đơn hàng
  Future<void> saveOrderToFirebase(FoodOrder order) async {
    print("Đang tiến hành đặt hàng");
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
  }

  //6.4

  // Lấy danh sách đơn hàng của một người dùng
  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  //6.5

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    return await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});
  }

  //6.6

  // Hủy đơn hàng
  Future<void> cancelOrder(String orderId) {
    return updateOrderStatus(orderId, 'Đã huỷ');
  }



  //7 Voucher

  //7.1

  // Upload data voucher có sẵn ban đầu lên FireBase
  Future<void> uploadInitialVouchers() async {
    for (var voucher in initialVouchers) {
      if (!await isVoucherExist(voucher.id)) {
        await setVoucher(voucher);
      }
    }
    print('All new vouchers uploaded to Firestore!');
  }

  //7.2

  // Thêm mới hoặc update voucher hiện có
  Future<void> setVoucher(Voucher voucher) async {

    await _firestore.collection('vouchers').doc(voucher.id).set({
      'voucherName': voucher.voucherName,
      'displayName': voucher.displayName,
      'discountPercentage': voucher.discountPercentage,
      'maxDiscount': voucher.maxDiscount,
      'minOrderValue': voucher.minOrderValue,
      'maxUses': voucher.maxUses,
      'currentUses': voucher.currentUses,
      'startDate': voucher.startDate,
      'expiryDate': voucher.expiryDate,
      'isHidden': voucher.isHidden,
    }, SetOptions(merge: true));

    print('Voucher ${voucher.voucherName} has been added/updated!');
  }
  // Check xem voucher đã tồn tại chưa trc khi load tránh trùng lặp
  Future<bool> isVoucherExist(String voucherId) async {
    final voucherSnapshot = await _firestore.collection('vouchers').doc(voucherId).get();
    return voucherSnapshot.exists;
  }

  //7.3

  // lấy thông tin all voucher
  Future<List<Voucher>> loadVouchers() async {
    final QuerySnapshot querySnapshot = await _firestore.collection('vouchers').get();
    final List<Voucher> vouchers = [];

    for (var doc in querySnapshot.docs) {
      vouchers.add(Voucher.fromDocument(doc));
    }
    return vouchers;
  }

//Lưu voucher mà user đã sử dụng
 /* Future<void> addUserUsedVoucher(String userId, String voucherId) async {
    await _firestore.collection('users').doc(userId).collection('usedVouchers').doc(voucherId).set({
      'useDate': DateTime.now(),
      // Bạn có thể thêm bất kỳ dữ liệu khác bạn muốn lưu trữ
    });
  }

  */



  //7.4

  // Kiểm tra xem người dùng đã sử dụng voucher này chưa và ngăn dùng lần 2:
  Future<bool> hasUserUsedVoucher(String userId, String voucherId) async {
    final voucherSnapshot = await _firestore.collection('users').doc(userId).collection('usedVouchers').doc(voucherId).get();
    return voucherSnapshot.exists;
  }

  //7.5

  // Xoá voucher
  Future<void> deleteVoucher(String voucherId) async {
    await _firestore.collection('vouchers').doc(voucherId).delete();
    print('Voucher with id $voucherId has been deleted!');
  }


  //7.6
  // Hoàn trả lượt dùng khi huỷ đơn
  Future<void> decreaseVoucherUses(String voucherId) async {
    try {
      DocumentReference voucherRef =
      FirebaseFirestore.instance.collection('vouchers').doc(voucherId);

      // Giảm giá trị của currentUses đi 1
      await voucherRef.update({'currentUses': FieldValue.increment(-1)});

    } catch (e) {
      print('Error decreasing voucher uses: $e');
    }
  }
  // Xoá đánh dấu user đã dùng mã
  Future<void> deleteUserUsedVoucher(String userId, String voucherId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('usedVouchers')
          .doc(voucherId)
          .delete();
    } catch (e) {
      print('Error deleting user used voucher: $e');
    }
  }


//Các phương thức khác thêm tại đây
}


//Hàm này nằm ngoài FireBase Service
// Chuyển data có sẵn thành dạng Map để lưu trữ lên FireBase
extension FoodItemExtension on FoodItem {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'searchName': generateSearchName(name),
      // Dùng để tìm kiếm theo chuỗi liền
      'lowerName': generateLowerNameArray(name),
      // Thêm hàm này để tạo mảng từ
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  // Thêm hàm này vào extension chuyển về chữ liền
  String generateSearchName(String name) {
    return name.replaceAll(' ', '').toLowerCase();
  }
// Mục đính tìm kiếm món ăn
  List<String> generateLowerNameArray(String name) {
    return name.toLowerCase().split(' ');
  }

}
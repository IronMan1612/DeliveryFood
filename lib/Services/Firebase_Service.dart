import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Model/Address.dart';
import '../Model/Order.dart';
import '../Model/Voucher.dart';
import '../Model/food_category.dart';
import '../Model/food_item.dart';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//1 Danh mục
  //1.1 Lấy list data Category
  Future<List<FoodCategory>> fetchCategoriesData() async {
    List<FoodCategory> categories = [];

    QuerySnapshot querySnapshot =
        await _firestore.collection('categories').get();

    for (var doc in querySnapshot.docs) {
      categories.add(FoodCategory.fromMap(doc.data() as Map<String, dynamic>));
    }

    return categories;
  }

  //1.2 Thêm mới hoặc update Danh mục nếu đã tồn tại
  Future<void> setCategory(FoodCategory category) async {
    await _firestore.collection('categories').doc(category.id).set({
      'id': category.id,
      'name': category.name,
      'imagePath': category.imagePath,
      'foods': category.foods.toList(),
    }, SetOptions(merge: true));
  }
  //1.3 Kiểm tra id và tên có tồn tại không để thay đổi
  Future<Map<String, bool>> doesCategoryExist({
    String? currentCategoryId,
    String? categoryId,
    String? categoryName
  }) async {
    final categoriesSnapshot = await _firestore.collection('categories').get();
    bool idExists = false;
    bool nameExists = false;

    for (var category in categoriesSnapshot.docs) {
      if (categoryId != null &&
          category.id.toLowerCase() == categoryId.toLowerCase() &&
          category.id.toLowerCase() != currentCategoryId?.toLowerCase()) { // Thêm điều kiện này
        idExists = true;
      }
      if (categoryName != null) {
        String firebaseName = category.data()['name'].trim().toLowerCase().replaceAll(" ", "");
        String processedCategoryName = categoryName.trim().toLowerCase().replaceAll(" ", "");

        if (firebaseName == processedCategoryName && category.id != currentCategoryId) {
          nameExists = true;
        }
      }

      if (idExists && nameExists) break; // Không cần kiểm tra thêm nếu cả hai đều tồn tại
    }

    return {'idExists': idExists, 'nameExists': nameExists};
  }


  //1.4 để lấy ID lớn nhất của danh mục , sau khi thêm mới sẽ +1
  Future<int> getMaxCategoryId() async {
    int maxId = 0;
    List<FoodCategory> categories = await fetchCategoriesData();
    for (var category in categories) {
      if (RegExp(r'^[0-9]+$').hasMatch(category.id)) {  // Kiểm tra xem ID có phải là số không
        int currentId = int.parse(category.id);
        if (currentId > maxId) {
          maxId = currentId;
        }
      }
    }
    return maxId;
  }


  //1.5 Xoá danh mục
  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

// lấy food theo mỗi danh mục
  Future<Map<String, List<FoodItem>>> fetchFoodsByCategory() async {
    Map<String, List<FoodItem>> foodsByCategory = {};

    // Lấy tất cả danh mục
    QuerySnapshot categorySnapshot = await _firestore.collection('categories').get();

    // Với mỗi danh mục, lấy các món ăn
    for (var categoryDoc in categorySnapshot.docs) {
      FoodCategory category = FoodCategory.fromMap(categoryDoc.data() as Map<String, dynamic>);

      if (category.foods.isNotEmpty) {
        QuerySnapshot foodSnapshot = await _firestore.collection('foods').where('id', whereIn: category.foods).get();

        List<FoodItem> foods = foodSnapshot.docs.map((foodDoc) {
          var data = foodDoc.data() as Map<String, dynamic>;
          return FoodItem.fromMap({
            ...data,
            'id': foodDoc.id,
          });
        }).toList();

        foodsByCategory[category.name] = foods;
      } else {
        foodsByCategory[category.name] = [];  // Danh mục này không có món ăn
      }
    }

    return foodsByCategory;
  }

// Kiểm tra id và tên của món ăn có tồn tại không
  Future<Map<String, bool>> doesFoodExist({String? currentFoodId, String? foodId, String? foodName}) async {
    final foodsSnapshot = await _firestore.collection('foods').get();
    bool idExists = false;
    bool nameExists = false;

    for (var food in foodsSnapshot.docs) {
      if (foodId != null && food.id.toLowerCase() == foodId.toLowerCase() && food.id != currentFoodId) {
        idExists = true;
      }
      if (foodName != null) {
        String firebaseName = food.data()['name'].trim().toLowerCase().replaceAll(" ", "");
        String processedFoodName = foodName.trim().toLowerCase().replaceAll(" ", "");

        if (firebaseName == processedFoodName && food.id != currentFoodId) {
          nameExists = true;
        }
      }

      if (idExists && nameExists) break;
    }

    return {'idExists': idExists, 'nameExists': nameExists};
  }

  // Thêm mới hoặc update  món ăn nếu đã tồn tại
  Future<void> setFood(FoodItem food) async {
    await _firestore
        .collection('foods')
        .doc(food.id)
        .set(food.toMap(), SetOptions(merge: true));
  }

  // Cập nhật lại danh mục của Food
  Future<void> updateFoodCategory(String foodId, String oldCategoryId, String newCategoryId) async {
    // Tham chiếu đến Firestore
    final firestore = FirebaseFirestore.instance;

    // Cập nhật danh mục cũ: xóa foodId khỏi danh sách
    DocumentReference oldCategoryRef = firestore.collection('categories').doc(oldCategoryId);
    await oldCategoryRef.update({
      'foods': FieldValue.arrayRemove([foodId])
    });

    // Cập nhật danh mục mới: thêm foodId vào danh sách
    DocumentReference newCategoryRef = firestore.collection('categories').doc(newCategoryId);
    await newCategoryRef.update({
      'foods': FieldValue.arrayUnion([foodId])
    });
  }
  // Lấy ID lớn nhất từ danh sách món ăn
  Future<int> getMaxFoodId() async {
    int maxId = 0;

    // Lấy toàn bộ món ăn từ Firestore
    final foodsSnapshot = await _firestore.collection('foods').get();

    // Duyệt qua từng món ăn và tìm ID lớn nhất
    for (var food in foodsSnapshot.docs) {
      if (RegExp(r'^[0-9]+$').hasMatch(food.id)) {
        int currentId = int.parse(food.id);
        if (currentId > maxId) {
          maxId = currentId;
        }
      }
    }
    return maxId;
  }
 // Thêm 1 món và danh mục
  Future<void> addFoodToCategory(String foodId, String categoryId) async {
    final firestore = FirebaseFirestore.instance;

    // Cập nhật danh mục bằng cách thêm foodId vào danh sách
    DocumentReference categoryRef = firestore.collection('categories').doc(categoryId);
    await categoryRef.update({
      'foods': FieldValue.arrayUnion([foodId])
    });
  }


  Future<void> deleteFood(String foodId) async {
    await _firestore.collection('foods').doc(foodId).delete();
  }




  // check banner đã tồn tại hay chưa
  Future<bool> isBannerExist(String bannerPath) async {
    final bannerSnapshot = await FirebaseFirestore.instance.collection('banners').doc(bannerPath).get();

    return bannerSnapshot.exists;
  }

// Thêm mới hoặc update nếu đã tồn tại
  Future<void> setBanner(String banner) async {
    await _firestore.collection('banners').doc(banner).set({
      'imagePath': banner,
    });
  }


  // 1. Thêm địa chỉ mới
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


// 2. Tải tất cả địa chỉ của một người dùng
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

// 3. Cập nhật một địa chỉ cụ thể
  Future<void> updateAddressInFirestore(String addressId, Address newAddress) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).collection('addresses').doc(addressId).set(newAddress.toMap());
    }
  }

// 4. Xóa một địa chỉ cụ thể
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


// Lấy data Food theo cùng ID để tăng số lượng món lên thay vì tạo 1 món y hệt trong giỏ
  // Lấy item để hiển thị chi tiết order
  Future<FoodItem?> getFoodItemById(String foodId) async {
    DocumentSnapshot doc =
    await _firestore.collection('foods').doc(foodId).get();
    if (doc.exists) {
      return FoodItem.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }


  // Phương thức lấy thông tin  all đơn hàng dựa
// Phương thức lấy tất cả các đơn hàng

  double parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }

  Future<List<FoodOrder>> getAllOrders() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('orders').get();

      List<FoodOrder> orders = querySnapshot.docs.map((document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        String id = data['id'] ?? '';
        String userId = data['userId'] ?? '';
        Map<FoodItem, int> items = Map<FoodItem, int>.from(
          (data['orderItems'] as Map<String, dynamic> ?? {}).map(
                (key, value) {
              FoodItem item = FoodItem(
                id: key,
                name: value['name'] ?? '',
                note: value['note'] ?? '',
                description: value['description'] ?? '',
                price: parseDouble(value['price']),
                imagePath: value['imagePath'] ?? '',
                category: value['category'] ?? '',
                isAvailable: value['isAvailable'] ?? false,
              );
              return MapEntry(item, value['quantity'] ?? 0);
            },
          ),
        );
        Address address = Address.fromMap(data['address'] ?? {});
        double totalPrice = parseDouble(data['totalPrice']);
        int totalItems = data['totalItems'] ?? 0;
        String voucherId = data['voucherId'] ?? '';
        double discount = parseDouble(data['discount']);
        double totalWithDiscount = parseDouble(data['totalWithDiscount']);
        DateTime orderDate = DateTime.parse(data['orderDate'] ?? '');
        String status = data['status'] ?? '';

        return FoodOrder(
          id: id,
          userId: userId,
          items: items,
          address: address,
          totalPrice: totalPrice,
          totalItems: totalItems,
          voucherId: voucherId,
          discount: discount,
          totalWithDiscount: totalWithDiscount,
          orderDate: orderDate,
          status: status,
        );
      }).toList();

      return orders;
    } catch (error) {
      throw error.toString();
    }
  }






  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    return await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});
  }


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


  // lấy thông tin all voucher
  Future<List<Voucher>> loadVouchers() async {
    final QuerySnapshot querySnapshot = await _firestore.collection('vouchers').get();
    final List<Voucher> vouchers = [];

    for (var doc in querySnapshot.docs) {
      vouchers.add(Voucher.fromDocument(doc));
    }
    return vouchers;
  }


  //1.3 Kiểm tra id và tên có tồn tại không để thay đổi
  Future<Map<String, bool>> doesVoucherExist({
    String? currentVoucherId,
    String? voucherId,
    String? voucherName
  }) async {
    final vouchersSnapshot = await _firestore.collection('vouchers').get();
    bool idExists = false;
    bool nameExists = false;

    for (var voucher in vouchersSnapshot.docs) {
      if (voucherId != null &&
          voucher.id.toLowerCase() == voucherId.toLowerCase() &&
          voucher.id.toLowerCase() != currentVoucherId?.toLowerCase()) {
        idExists = true;
      }
      if (voucherName != null) {
        String firebaseName = voucher.data()['voucherName'].trim().toLowerCase().replaceAll(" ", "");
        String processedVoucherName = voucherName.trim().toLowerCase().replaceAll(" ", "");

        if (firebaseName == processedVoucherName && voucher.id != currentVoucherId) {
          nameExists = true;
        }
      }

      if (idExists && nameExists) break;
    }

    return {'idExists': idExists, 'nameExists': nameExists};
  }

  //1.4 để lấy ID lớn nhất của voucher , sau khi thêm mới sẽ +1
  Future<int> getMaxIdVoucher() async {
    int maxId = 0;
    final vouchersSnapshot = await _firestore.collection('vouchers').get();

    for (var voucher in vouchersSnapshot.docs) {
      if (RegExp(r'^[0-9]+$').hasMatch(voucher.id)) {
        int currentId = int.parse(voucher.id);
        if (currentId > maxId) {
          maxId = currentId;
        }
      }
    }
    return maxId;
  }

  // Xoá voucher
  Future<void> deleteVoucher(String voucherId) async {
    await _firestore.collection('vouchers').doc(voucherId).delete();
    print('Voucher with id $voucherId has been deleted!');
  }

//Lưu voucher mà user đã sử dụng
  Future<void> addUserUsedVoucher(String userId, String voucherId) async {
    await _firestore.collection('users').doc(userId).collection('usedVouchers').doc(voucherId).set({
      'useDate': DateTime.now(),
      // Bạn có thể thêm bất kỳ dữ liệu khác bạn muốn lưu trữ
    });
  }
  // Kiểm tra xem người dùng đã sử dụng voucher này chưa và ngăn dùng lần 2:
  Future<bool> hasUserUsedVoucher(String userId, String voucherId) async {
    final voucherSnapshot = await _firestore.collection('users').doc(userId).collection('usedVouchers').doc(voucherId).get();
    return voucherSnapshot.exists;
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
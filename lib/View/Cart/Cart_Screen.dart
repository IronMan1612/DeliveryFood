import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/Address.dart';
import '../../Model/Order.dart';
import '../../Model/Voucher.dart';
import '../../Services/Firebase_Service.dart';
import '../../Widgets/food_list_inCart.dart';
import '../../components/Navbar/Bottom_Navigation_Bar.dart';
import '../HomeScreen/add_to_Cart.dart';
import '../Register/signIn.dart';
import '../Voucher/chooseVoucher.dart';
import 'address_screen.dart';
import 'check_Cart_logic.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  _CartScreenState createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  late Future<void> loadCartFuture;
  late CartLogic cartLogic;

  final _firestore = FirebaseFirestore.instance;
  bool isOrdering = false;

  Voucher? selectedVoucher;
  double discount = 0.0;
  double totalWithDiscount = 0.0;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    cartLogic = CartLogic(context); // Tạo một instance mới của CartLogic
    loadCartFuture = Provider.of<Cart>(context, listen: false).loadCart();
    updateStateValues();
  }
  void updateStateValues() {
    var cartValues = cartLogic.updateCartValues(selectedVoucher);
    setState(() {
      discount = cartValues['discount']!;
      totalWithDiscount = cartValues['totalWithDiscount']!;
      total = cartValues['total']!;
    });
  }


  void checkVoucherAndUpdateCart() {
    updateStateValues();
    if (selectedVoucher != null && selectedVoucher!.minOrderValue > total) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const  Text("Thông báo",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center),
          content: Text("Đơn hàng đã cập nhật! Giá trị đơn đang nhỏ hơn mức tối thiểu ${selectedVoucher!.minOrderValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ của voucher nên không thể áp dụng. Hãy sử dụng voucher khác hoặc tiếp tục đặt đơn mà không ưu đãi bạn nhé!",
              textAlign: TextAlign.center),

          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: const Text('OK', style: TextStyle(color: Colors.orange)),
                    onPressed: () {
                      setState(() {
                        selectedVoucher = null;
                      });
                      Navigator.of(ctx).pop();
                      updateStateValues();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AddressScreen>(
      builder: (context, addressNotifier, child) {
        var selectedAddress = addressNotifier.selectedAddress;
        var currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          Future.delayed(Duration.zero, () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(
                "Vui lòng đăng nhập để tiếp tục",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              duration: const Duration(seconds: 2),
            ));
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => SignIn()));
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Giỏ hàng'),
            backgroundColor: Colors.orange,
            elevation: 0,
          ),
          body: FutureBuilder<void>(
            future: loadCartFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
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
              }

              if (snapshot.hasError) {
                return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
              }
              var cart = Provider.of<Cart>(context);
              var items = cart.items;

              // Kiểm tra nếu giỏ hàng trống
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    "Giỏ hàng trống",
                    style: TextStyle(color: Colors.orange, fontWeight:FontWeight.bold ,fontSize: 32),
                  ),
                );
              }
              total = items.entries
                  .fold(0, (prev, e) => prev + (e.key.price * e.value));
              var amount = items.entries.fold(0, (prev, e) => prev + (e.value));
              totalWithDiscount = total - discount;
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (selectedAddress != null)
                          Card(
                            child: ListTile(
                              title: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text(selectedAddress.fullAddress, style: const TextStyle(color: Colors.black87, fontSize: 18)),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, color: Colors.black),
                                      const SizedBox(width: 6),
                                      Text(selectedAddress.name, style: const TextStyle(color: Colors.black, fontSize: 15)),
                                      const SizedBox(width: 25),
                                      const Icon(Icons.call, color: Colors.green),
                                      const SizedBox(width: 6),
                                      Text(selectedAddress.phoneNumber, style: const TextStyle(color: Colors.black, fontSize: 15)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.note, color: Colors.yellowAccent),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "Ghi chú: ${selectedAddress.note}",
                                          style: const TextStyle(color: Colors.black38, fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                child: const Text("Thay đổi"),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                                  foregroundColor: MaterialStateProperty.all(Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddressPage())
                                  ).then((selectedAddr) {
                                    if (selectedAddr != null) {
                                      addressNotifier.selectedAddress = selectedAddr as Address;
                                    }
                                  });
                                },
                              ),
                            ),
                          )
                        else
                          Card(
                            child: ListTile(
                              title: const Padding(
                                padding: EdgeInsets.all(30.0),
                                child: Center(
                                  child: Text(
                                    "Điền thông tin giao hàng",
                                    style: TextStyle(color: Colors.orange, fontSize: 23),
                                  ),
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AddressPage())
                                ).then((selectedAddr) {
                                  if (selectedAddr != null) {
                                    addressNotifier.selectedAddress = selectedAddr as Address;
                                  }
                                });
                              },
                            ),
                          ),
                        const SizedBox(height:10),

                          // Hiển thị List món ăn có thể thu gọn hoặc xem thêm từ file Widgets/food_list_inCart
                        FoodListCart(items: items, cart: cart, onCartChanged: checkVoucherAndUpdateCart),

                        //


                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Tổng cộng ($amount món)"),
                                    Text(
                                        "${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ"),
                                  ],
                                ),
                                const SizedBox(height:3),
                                const Divider(),
                                const SizedBox(height:3),
                                const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Phí giao hàng"),
                                    Text("Miễn phí"),
                                  ],
                                ),
                                const SizedBox(height:3),
                                const Divider(),
                                const SizedBox(height:3),
                                if (selectedVoucher != null) ...[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Mã khuyến mãi"),
                                      Text("-${discount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ"),
                                    ],
                                  ),
                                  const SizedBox(height:3),
                                  const Divider(),
                                  const SizedBox(height:3),

                                ],
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Thanh toán",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Column(
                                      children: [
                                        Text(
                                            "${totalWithDiscount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ",
                                            style: const TextStyle(
                                                color: Colors.orange,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 7),
                                        const Text(" Đã bao gồm thuế")
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.card_giftcard,
                                color: Colors.orange),
                            title: const Text("Thêm voucher",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: selectedVoucher != null
                                ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text("Đã áp dụng",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold)),
                            )
                                : const Text("Chọn voucher >",
                                style: TextStyle(color: Colors.grey)),
                            onTap: () async {
                              Voucher? chosenVoucher = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChooseVoucher(
                                      cartTotal: total,
                                      userId: '',
                                    )),
                              );
                              if (chosenVoucher != null) {
                                double calculatedDiscount =
                                    (chosenVoucher.discountPercentage / 100) *
                                        total;
                                if (calculatedDiscount >
                                    chosenVoucher.maxDiscount) {
                                  calculatedDiscount = chosenVoucher.maxDiscount;
                                }
                                setState(() {
                                  selectedVoucher = chosenVoucher;
                                  discount = calculatedDiscount;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Đã áp dụng "${chosenVoucher.voucherName}"'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height:10),
                        const Card(
                          child: ListTile(
                            leading: Icon(Icons.info, color: Colors.blueAccent),
                            title: Text(
                              "Bằng việc nhấn Đặt hàng, bạn đã tuân thủ theo Điều khoản dịch vụ và Quy chế của chúng tôi.",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black),),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Thanh toán: ${totalWithDiscount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.orange),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              ),
                            ),
                            onPressed: isOrdering
                                ? null
                                : () async {
                              setState(() {
                                isOrdering = true;
                              });

                              try {
                                FirebaseService _firebaseService = FirebaseService();

                                if (addressNotifier.selectedAddress == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: const Text(
                                      "Vui lòng nhập địa chỉ",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    duration: const Duration(seconds: 2),
                                  ));
                                  return;
                                }

                                // Kiểm tra lại voucher
                                if (selectedVoucher != null) {
                                  Map<String, dynamic> validationResult = await cartLogic.isValidVoucher(selectedVoucher!);
                                  if (!validationResult['isValid']) {
                                    cartLogic.showVoucherAlert(validationResult['message']);
                                    setState(() {
                                      isOrdering = false;
                                      selectedVoucher = null; // Bỏ chọn voucher
                                      updateStateValues(); // Cập nhật giá trị của giỏ hàng
                                    });
                                    return;
                                  }
                                }


                                String orderId = await _firebaseService.getNewOrderId();
                                FoodOrder order = FoodOrder(
                                  id: orderId,
                                  userId: FirebaseAuth.instance.currentUser!.uid,
                                  items: items,
                                  address: addressNotifier.selectedAddress!,
                                  totalPrice: total,
                                  totalItems: amount,
                                  voucherId: selectedVoucher?.id,
                                  discount: discount,
                                  totalWithDiscount: totalWithDiscount,
                                  orderDate: DateTime.now(),
                                  status: "Chờ xác nhận",
                                );

                                await _firebaseService.saveOrderToFirebase(order);
                                await _firebaseService.clearUserCart(
                                    FirebaseAuth.instance.currentUser!.uid);

                                // Cập nhật thông tin voucher và đánh dấu người dùng đã sử dụng voucher
                                if (selectedVoucher != null) {
                                  await _firestore.collection('vouchers').doc(selectedVoucher!.id).update({
                                    'currentUses': FieldValue.increment(1)
                                  });

                                  final User? currentUser = FirebaseAuth.instance.currentUser;
                                  final String userId = currentUser!.uid;

                                  // Lưu trữ thông tin về việc người dùng đã sử dụng voucher
                                  await _firestore.collection('users').doc(userId).collection('usedVouchers').doc(selectedVoucher!.id).set({
                                    'usedAt': DateTime.now(),
                                    'orderId': orderId, //  orderId
                                    'displayName': selectedVoucher!.displayName,
                                    'expiryDate': selectedVoucher!.expiryDate,
                                  });
                                }


                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "Đặt hàng thành công!",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                    ),
                                    backgroundColor: Colors.green[400],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NavBar(initialPage: 2)),
                                      (Route<dynamic> route) => false,
                                );
                              } catch (error) {
                                print('Error ordering: $error');
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Đặt hàng thất bại: $error'),
                                  backgroundColor: Colors.red,
                                ));
                              } finally {
                                setState(() {
                                  isOrdering = false;
                                });
                              }
                            },
                            child: isOrdering
                                ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                : const Text(
                              'Đặt hàng',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                ],
              );
            },
          ),
        );
      },
    );
  }
}


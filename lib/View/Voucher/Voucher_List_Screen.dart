import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:DeliveryFood/View/Voucher/voucherDetail.dart';
import 'package:DeliveryFood/View/Voucher/voucher_load_logic.dart';

import '../../Model/Voucher.dart';
import '../Register/signIn.dart';

class VoucherList extends StatefulWidget {
  const VoucherList({super.key});

  @override
  _VoucherListState createState() => _VoucherListState();
}

class _VoucherListState extends State<VoucherList> {
  final VoucherLoader _voucherService = VoucherLoader();

  List<Voucher> allVouchers = [];
  Set<String> usedVouchers = <String>{};

  @override
  void initState() {
    super.initState();
    _loadAllDataVouchers().catchError((error) {
      print("Error occurred: $error");
      // Handle or show an error message to the user if needed.
    });
  }

  Future<void> _loadAllDataVouchers() async {
    List<dynamic> data = await _voucherService.loadAllDataVouchers();
    usedVouchers = data[0] as Set<String>;
    allVouchers = data[1] as List<Voucher>;

    if (mounted) {  // Check if the widget is still in the tree
      setState(() {});
    }
  }


  Future<void> _handleRefresh() async {
    await _loadAllDataVouchers();

    if (mounted) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    // Kiểm tra người dùng đã đăng nhập hay chưa
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            "Vui lòng đăng nhập để tiếp tục",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          duration: const Duration(seconds: 1),
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
      });
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách Voucher'),
          backgroundColor: Colors.orange, // Màu nền của AppBar
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),  // Đặt kích thước mong muốn cho TabBar
            child: Material(
              color: Colors.white,  // Màu nền của TabBar
              child: TabBar(
                labelColor: Colors.red, // Màu văn bản khi một tab được chọn
                unselectedLabelColor: Colors.black, // Màu văn bản khi tab không được chọn
                indicatorColor: Colors.redAccent, // Màu của chỉ báo gạch dưới khi một tab được chọn

                tabs: [
                  Tab(text: 'Có hiệu lực'),
                  Tab(text: 'Đã dùng'),
                  Tab(text: 'Hết hiệu lực'),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            _buildVoucherListView(
                    (voucher) => !usedVouchers.contains(voucher.id) && !voucher.isHidden && voucher.maxUses > voucher.currentUses && DateTime.now().isBefore(voucher.expiryDate)),
            Opacity(
                opacity: 0.5,
                child: _buildVoucherListView((voucher) => usedVouchers.contains(voucher.id))),
            Opacity(
              opacity: 0.5,
              child: _buildVoucherListView(
                      (voucher) => !usedVouchers.contains(voucher.id) && voucher.maxUses <= voucher.currentUses  || DateTime.now().isAfter(voucher.expiryDate)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherListView(bool Function(Voucher) filterFunction) {
    DateTime now = DateTime.now();
    List<Voucher> filteredVouchers = allVouchers.where(filterFunction).toList();

    if (filteredVouchers.isEmpty) {
      return const Center(
        child: Text("Bạn chưa có khuyến mãi nào" , style: TextStyle(color: Colors.orange, fontSize: 25)),
      );
    }
    return RefreshIndicator(
      onRefresh: _handleRefresh,

      child: ListView(
        children: allVouchers.where((voucher) {
          return filterFunction(voucher);
        }).map((Voucher voucher) {
          DateTime expiryDate = voucher.expiryDate;
          Duration difference = expiryDate.difference(now);
          String timeLeft = '';
          if (now.isAfter(expiryDate)) {
            timeLeft = 'Đã hết hạn';
          } else if (difference.inMinutes < 60) {
            timeLeft = 'Hết hạn trong: ${difference.inMinutes} phút';
          } else if (difference.inHours < 24) {
            timeLeft = 'Hết hạn trong: ${difference.inHours} giờ';
          } else {
            timeLeft = 'Hết hạn trong: ${difference.inDays} ngày';
          }

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Container(
                    width: 110,
                    height: 100,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/voucherSPF.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(voucher.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),  // Sửa tại đây
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Ưu đãi có hạn',
                            style: TextStyle(color: Colors.orange, fontSize: 10),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              difference.inDays >= 7
                                  ? 'HSD: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'
                                  : timeLeft,
                              style: TextStyle(
                                fontSize: 12,
                                color: (difference.inDays < 7 || difference.inHours < 24 || difference.inMinutes < 60)
                                    ? Colors.orange
                                    : Colors.black,
                              ),
                            ),
                            TextButton(
                              child: const Text(
                                'Điều kiện',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => VoucherDetail(voucherId: voucher.id)));  // Sửa tại đây
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
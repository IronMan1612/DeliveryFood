import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Services/Firebase_Service.dart';
import '../../Widgets/order_list_item.dart';
import '../Register/signIn.dart';
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  FirebaseService firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {}); // This will refresh the UI.
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;
    final _firestore = FirebaseFirestore.instance;
    // Kiểm tra người dùng đã đăng nhập hay chưa
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
      return const Scaffold();  // Empty scaffold to avoid building the rest of the UI.
    }


    Stream<QuerySnapshot> getUserOrders(String userId, List<String> statuses) {
      return _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: statuses)
          .orderBy('orderDate', descending: true)
          .snapshots();
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn hàng'),
        backgroundColor: Colors.orange,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Material(
            color: Colors.white,  // Màu nền của TabBar
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.redAccent,
              tabs: const [
                Tab(text: 'Đang đến'),
                Tab(text: 'Hoàn thành'),
                Tab(text: 'Đã huỷ'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder(
            stream: getUserOrders(currentUser.uid, ['Chờ xác nhận', 'Đang giao hàng', 'Đang xử lý']),
            builder: (context, snapshot) {
              return _buildOrderList(snapshot);
            },
          ),
          StreamBuilder(
            stream: getUserOrders(currentUser.uid,['Hoàn thành'] ),
            builder: (context, snapshot) {
              return _buildOrderList(snapshot);
            },
          ),
          StreamBuilder(
            stream: getUserOrders(currentUser.uid, ['Đã huỷ']),
            builder: (context, snapshot) {
              return _buildOrderList(snapshot);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return Center(child: Text('Lỗi: ${snapshot.error}'));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text(
          "Bạn chưa đặt món",
          style: TextStyle(color: Colors.orange, fontWeight:FontWeight.bold ,fontSize: 32),
        ),
      );
    }

    var orders = snapshot.data!.docs;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return OrderListItem(order: order);
        },
      ),
    );
  }

}

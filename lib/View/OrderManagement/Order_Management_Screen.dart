import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_list_item.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({Key? key}) : super(key: key);

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> orderStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    orderStream = getOrders(['Chờ xác nhận', 'Đang giao hàng', 'Đang xử lý', 'Hoàn thành', 'Đã huỷ']);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Nhập ID đơn hàng...",
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: _searchController.text.trim().isEmpty
                ? null
                : IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _initStream();
                });
              },
            ),
          ),
          onChanged: _onSearchChanged,
        ),
        backgroundColor: Colors.orange,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.redAccent,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Đang xử lý'),
                Tab(text: 'Hoàn thành'),
                Tab(text: 'Đã huỷ'),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Tắt bàn phím khi chạm vào vùng trống
          FocusScope.of(context).unfocus();
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(orderStream),
            _buildOrderList(getOrders(['Chờ xác nhận', 'Đang giao hàng', 'Đang xử lý'])),
            _buildOrderList(getOrders(['Hoàn thành'])),
            _buildOrderList(getOrders(['Đã huỷ'])),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(Stream<QuerySnapshot> orderStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: orderStream,
      builder: (context, snapshot) {
        return _buildOrderListContent(snapshot);
      },
    );
  }

  Widget _buildOrderListContent(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      print('Error: ${snapshot.error}');
      return Center(child: Text('Lỗi: ${snapshot.error}'));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text(
          "Không có đơn hàng nào",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20),
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

  Future<void> _refresh() async {
    setState(() {});
  }

  Stream<QuerySnapshot> getOrders(List<String> statuses) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', whereIn: statuses)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  void _onSearchChanged(String orderId) {
    if (orderId.isEmpty) {
      setState(() {
        orderStream = getOrders(['Chờ xác nhận', 'Đang giao hàng', 'Đang xử lý', 'Hoàn thành', 'Đã huỷ']);
      });
    } else {
      setState(() {
        orderStream = FirebaseFirestore.instance
            .collection('orders')
            .where('id', isEqualTo: orderId)
            .snapshots();
      });
    }
  }

  void _initStream() {
    setState(() {
      orderStream = getOrders(['Chờ xác nhận', 'Đang giao hàng', 'Đang xử lý', 'Hoàn thành', 'Đã huỷ']);
    });
  }
}

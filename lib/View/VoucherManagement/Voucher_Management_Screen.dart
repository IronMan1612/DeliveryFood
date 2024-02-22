
import 'package:flutter/material.dart';
import '../../Model/Voucher.dart';
import '../../Services/Firebase_Service.dart';
import 'AddVoucher.dart';
import 'EditVoucher.dart';

class VoucherManagementScreen extends StatefulWidget {
  const VoucherManagementScreen({super.key});

  @override
  _VoucherManagementScreenState createState() => _VoucherManagementScreenState();
}

class _VoucherManagementScreenState extends State<VoucherManagementScreen> {

  final FirebaseService _firebaseService = FirebaseService(); // Khởi tạo đối tượng FirebaseService

  List<Voucher> allVouchers = [];

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }
  Future<void> _handleRefresh() async {
    await _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    try {
      List<Voucher> vouchers = await _firebaseService.loadVouchers();

      setState(() {
        allVouchers = vouchers;
      });
    } catch (error) {
      print("Error loading vouchers: $error");
      // Xử lý hoặc hiển thị thông báo lỗi nếu cần.
    }
  }

  Future<void> _deleteVoucher(String voucherId) async {
    try {
      await _firebaseService.deleteVoucher(voucherId);
      await _loadVouchers(); // Sau khi xóa, tải lại danh sách Voucher
    } catch (error) {
      print("Error deleting voucher: $error");
      // Xử lý hoặc hiển thị thông báo lỗi nếu cần.
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách Voucher'),
          backgroundColor: Colors.orange,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Material(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.red,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.redAccent,
                tabs: [
                  Tab(text: 'ALL'),
                  Tab(text: 'Public'),
                  Tab(text: 'Hidden'),
                  Tab(text: 'OutDate'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildVoucherListView((voucher) => true),  // Hiển thị tất cả
            _buildVoucherListView((voucher) => !voucher.isHidden),
            _buildVoucherListView((voucher) => voucher.isHidden),
            _buildVoucherListView((voucher) => DateTime.now().isAfter(voucher.expiryDate)),
          ],


        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddVoucherScreen()),
            ).then((newVoucher) {
              if (newVoucher != null) {
                _handleRefresh();
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildVoucherListView(bool Function(Voucher) filterFunction) {
    DateTime now = DateTime.now();
    List<Voucher> filteredVouchers = allVouchers.where(filterFunction).toList();

    if (filteredVouchers.isEmpty) {
      return const Center(
        child: Text("Không có Voucher nào phù hợp", style: TextStyle(color: Colors.orange, fontSize: 25)),
      );
    }
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 70.0),
        children: filteredVouchers.map((Voucher voucher) {
          DateTime expiryDate = voucher.expiryDate;
          Duration difference = expiryDate.difference(now);
          String timeLeft = '';


          String id = voucher.id;
          int currentUses = voucher.currentUses;
          int maxUses = voucher.maxUses;

          if (now.isAfter(expiryDate)) {
            timeLeft = 'Đã hết hạn';
          } else if (difference.inMinutes < 60) {
            timeLeft = 'Hết hạn trong: ${difference.inMinutes} phút';
          } else if (difference.inHours < 24) {
            timeLeft = 'Hết hạn trong: ${difference.inHours} giờ';
          } else {
            timeLeft = 'Hết hạn trong: ${difference.inDays} ngày';
          }

          return Opacity(
            opacity: voucher.isHidden ? 0.5 : 1.0,
            child: Card(
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
                          Text(voucher.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Text(
                            'ID:  $id',
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Lượt dùng:  $currentUses / $maxUses',
                            style: const TextStyle(color: Colors.orange, fontSize: 14),
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
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditVoucher(voucher: voucher),
                                        ),
                                      ).then((editVoucher) {
                                        if (editVoucher != null) {
                                          _handleRefresh();
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Gọi hàm xử lý xóa ở đây
                                      _showDeleteConfirmationDialog(voucher.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  Future<void> _showDeleteConfirmationDialog(String voucherId) async {
    Voucher voucher = allVouchers.firstWhere((v) => v.id == voucherId);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Xác nhận",
            textAlign: TextAlign.center,
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                const TextSpan(
                  text: "Bạn sẽ xóa Voucher ",
                  style: TextStyle(fontSize: 15),
                ),
                TextSpan(
                  text: voucher.voucherName,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    child: const Text(
                      "Hủy",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    child: const Text(
                      "Xóa",
                      style: TextStyle(color: Colors.orange),
                    ),
                    onPressed: () async {
                      try {
                        await _deleteVoucher(voucherId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Xóa thành công'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } catch (e) {
                        print("Error deleting voucher: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lỗi khi xóa Voucher'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lap9/View/Voucher/voucherDetail.dart';
import '../../Model/Voucher.dart';
import 'package:lap9/View/Voucher/voucher_load_logic.dart';
class ChooseVoucher extends StatefulWidget {
  final double cartTotal;
  final String userId;

  ChooseVoucher({required this.cartTotal, required this.userId});

  @override
  _ChooseVoucherState createState() => _ChooseVoucherState();
}

class _ChooseVoucherState extends State<ChooseVoucher> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Voucher? _selectedVoucher;
  Voucher? _lastSuccessfulSearchVoucher;
  String searchQuery = '';
  final searchController = TextEditingController();

  final VoucherLoader  _voucherService = VoucherLoader (); // Khởi tạo instance của VoucherLoader
  List<Voucher> allVouchers = [];   // Tạo list chứa all voucher
  Set<String> usedVouchers = <String>{}; // Tạo list voucher đã dùng theo từng User
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadAllDataVouchers();  //Chỉ load dữ liệu 1 lần khi vào
  }


  // 1.Hàm load tất cả voucher hợp lệ ( bỏ đi voucher đã dùng)
  Future<void> _loadAllDataVouchers() async {
    List<dynamic> data = await _voucherService.loadAllDataVouchers(); // Sử dụng hàm từ instance của voucher_load_logic
    usedVouchers = data[0] as Set<String>;
    allVouchers = sortVouchers(data[1] as List<Voucher>);
    setState(() {
      isLoadingData = false;
    });
  }

  // 2.Danh sách voucher có thể chọn ( chưa từng dùng , giá trị đơn , date )
  bool isValidVoucher(Voucher voucher) {
    return !usedVouchers.contains(voucher.id) &&
        voucher.minOrderValue <= widget.cartTotal &&
        voucher.maxUses > voucher.currentUses &&
        DateTime.now().isAfter(voucher.startDate) &&
        DateTime.now().isBefore(voucher.expiryDate);
  }
  // voucher còn hạn nhưng không đủ đơn tối thiểu
  bool isNotValidVoucher(Voucher voucher) {
    return !isValidVoucher(voucher) &&
        !isExpiredOrUsedVoucher(voucher);
  }
// voucher đã hết hạn , user đã từng dùng voucher trc đây
  bool isExpiredOrUsedVoucher(Voucher voucher) {
    return usedVouchers.contains(voucher.id) ||
        DateTime.now().isAfter(voucher.expiryDate) ||
        voucher.maxUses <= voucher.currentUses;
  }

// 3.Hiển thị danh sách voucher và ẩn đi voucher ẨN
  List<Voucher> sortVouchers(List<Voucher> vouchers) {
    List<Voucher> sortedVouchers = [];

    if (_lastSuccessfulSearchVoucher != null) {
      sortedVouchers.add(_lastSuccessfulSearchVoucher!);
    }

    sortedVouchers.addAll(vouchers.where((v) => !v.isHidden && v.id != _lastSuccessfulSearchVoucher?.id));

    return sortedVouchers;
  }

  //4.Check user đã dùng voucher chưa khi tìm kiếm ( gọi hàm Future trong FireBase_Service)
  bool hasUserUsedVoucher(String voucherId) {
    return usedVouchers.contains(voucherId);
  }

// 4.Tìm kiếm voucher và đưa nó lên đầu List và báo lỗi nếu có
  Future<void> searchVoucher() async {
    searchQuery = searchQuery.trim().toUpperCase();
    List<Voucher?> vouchers = await _voucherService.loadVouchers();

    Voucher? foundVoucher;
    try {
      foundVoucher = vouchers.firstWhere((v) => v?.voucherName == searchQuery);
    } catch (e) {
      foundVoucher = null;
    }

    if (foundVoucher == null) {
      _showDialog('Lỗi', 'Voucher không tồn tại');
      return;
    }

    // Kiểm tra voucher đã hết hạn hay chưa
    if (DateTime.now().isAfter(foundVoucher.expiryDate)) {
      _showDialog('Lỗi', 'Voucher đã hết hạn sử dụng');
      return;
    }
    if (foundVoucher.maxUses <= foundVoucher.currentUses) {
      _showDialog('Lỗi', 'Voucher đã hết lượt sử dụng');
      return;
    }

    bool hasUsed = await hasUserUsedVoucher(foundVoucher.id);
    if (hasUsed) {
      _showDialog('Lỗi', 'Bạn đã sử dụng hết lượt ưu đãi này');
      return;
    }

    if (widget.cartTotal < foundVoucher.minOrderValue) {
      _showDialog('Lỗi', 'Bạn không đủ điều kiện để sử dụng ưu đãi này');
      return;
    }

    // Xoá voucher ẩn trước đó khỏi danh sách nếu có
    if (_lastSuccessfulSearchVoucher != null) {
      allVouchers.removeWhere((v) => v.id == _lastSuccessfulSearchVoucher!.id && v.isHidden);
    }

    // Thêm voucher mới vào danh sách nếu nó không tồn tại
    if (!allVouchers.any((v) => v.id == foundVoucher?.id)) {
      allVouchers.insert(0, foundVoucher);
    }

    setState(() {
      // Xóa voucher nếu nó đã có trong danh sách
      allVouchers.removeWhere((v) => v.id == foundVoucher?.id);
      // Thêm voucher vào đầu danh sách
      allVouchers.insert(0, foundVoucher!);

      _selectedVoucher = foundVoucher;
      _lastSuccessfulSearchVoucher = foundVoucher;
      searchQuery = '';
      searchController.clear();
    });

  }
  //5. Báo lỗi tương ứng khi tìm kiếm voucher
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),  // Set text color to black
        ),

        content: Text(message, textAlign: TextAlign.center),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextButton(
                  child: const Text('OK', style: TextStyle(color: Colors.orange)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Voucher'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.search),
                      title: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Nhập voucher',
                          border: InputBorder.none,
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                searchController.text = '';  // xoá tìm kiếm
                              });
                            },
                          )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: searchQuery.trim().isEmpty
                      ? null
                      : () => searchVoucher(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: searchQuery.trim().isEmpty ? Colors.grey : Colors.orange,
                  ),
                  child: const Text('Thêm'),
                ),

              ],
            ),
          ),
          Expanded(
            child: isLoadingData
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.card_giftcard, size: 50, color: Colors.orange),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            )
                : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Các voucher có thể áp dụng"),
                ),
                ...allVouchers.where(isValidVoucher).map((voucher) => buildVoucherCard(voucher, context, true)).toList(),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Chưa đủ điều kiện áp dụng"),
                ),
                ...allVouchers.where(isNotValidVoucher).map((voucher) => buildVoucherCard(voucher, context, false)).toList(),

                /*
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Đã dùng & hết hạn"),
                ),
                ...allVouchers.where(isExpiredOrUsedVoucher).map((voucher) => buildVoucherCard(voucher, context, false)).toList(),
                */

              ],

            ),
          ),



          Container(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedVoucher);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
              ),
              child: const Text('Dùng Ngay'),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildVoucherCard(Voucher voucher, BuildContext context, bool canApply) {
    DateTime expiryDate = voucher.expiryDate;
    DateTime currentDate = DateTime.now();
    Duration difference = expiryDate.difference(currentDate);
    String timeLeft = 'Hết hạn trong: ${difference.inDays} ngày';

    if (difference.inDays < 1) {
      timeLeft = 'Hết hạn trong: ${difference.inHours} giờ';
      if (difference.inHours < 1) {
        timeLeft = 'Hết hạn trong: ${difference.inMinutes} phút';
      }
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
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
                          const SizedBox(height: 1),
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
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => VoucherDetail(voucherId: voucher.id)
                                      )
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (canApply)
              Positioned(
                top: 50,  // độ cao của ô tick
                right: 17.0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_selectedVoucher?.id == voucher.id) {
                        _selectedVoucher = null;
                      } else {
                        _selectedVoucher = voucher;
                      }
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _selectedVoucher?.id == voucher.id ? Colors.transparent : Colors.black.withOpacity(0.5)),
                      color: _selectedVoucher?.id == voucher.id ? Colors.orange : Colors.white,
                    ),
                    child: _selectedVoucher?.id == voucher.id
                        ? Center(child: const Icon(Icons.check, size: 14, color: Colors.white))
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

  }
}
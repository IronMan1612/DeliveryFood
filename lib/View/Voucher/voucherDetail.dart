import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoucherDetail extends StatefulWidget {
  final String voucherId;

  const VoucherDetail({super.key, required this.voucherId});

  @override
  _VoucherDetailState createState() => _VoucherDetailState();
}

class _VoucherDetailState extends State<VoucherDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> voucherFuture;

  @override
  void initState() {
    super.initState();
    voucherFuture = _firestore.collection('vouchers').doc(widget.voucherId).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: voucherFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.card_giftcard, size: 50, color: Colors.orange),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          );
        }

        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

        DateTime expiryDate = data['expiryDate'].toDate();
        DateTime now = DateTime.now();
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết Voucher'),
            backgroundColor: Colors.orange,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Row(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 110,
                        height: 90,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/voucherSPF.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(data['displayName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
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
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Phần hiển thị chi tiết voucher
                const SizedBox(height: 30),
                const Text('Mã voucher:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(data['voucherName']),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data['voucherName']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã sao chép'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text('Sao chép'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Hạn sử dụng:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                    '${data['startDate'].toDate().day.toString().padLeft(2, '0')}/${data['startDate'].toDate().month.toString().padLeft(2, '0')}/${data['startDate'].toDate().year} ${data['startDate'].toDate().hour.toString().padLeft(2, '0')}:${data['startDate'].toDate().minute.toString().padLeft(2, '0')}:${data['startDate'].toDate().second.toString().padLeft(2, '0')} - ${data['expiryDate'].toDate().day.toString().padLeft(2, '0')}/${data['expiryDate'].toDate().month.toString().padLeft(2, '0')}/${data['expiryDate'].toDate().year} ${data['expiryDate'].toDate().hour.toString().padLeft(2, '0')}:${data['expiryDate'].toDate().minute.toString().padLeft(2, '0')}:${data['expiryDate'].toDate().second.toString().padLeft(2, '0')}'
                ),
                const SizedBox(height: 20),
                const Text('Áp dụng:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Tất cả các món'),
                const SizedBox(height: 20),
                const Text('Phương thức giao hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Giao hàng tận nơi'),
                const SizedBox(height: 20),
                const Text('Điều kiện:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text('Giảm ${data['discountPercentage']}% giá trị đơn hàng'),
                const SizedBox(height: 7),
                Text(
                    'Áp dụng đơn tối thiểu ${data['minOrderValue'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ'
                ),
                const SizedBox(height: 7),
                Text(
                    'Giảm tối đa ${data['maxDiscount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ'
                ),
                const SizedBox(height: 7),
                Text('HSD ${data['expiryDate'].toDate().day.toString().padLeft(2, '0')}/${data['expiryDate'].toDate().month.toString().padLeft(2, '0')}/${data['expiryDate'].toDate().year} ${data['expiryDate'].toDate().hour.toString().padLeft(2, '0')}:${data['expiryDate'].toDate().minute.toString().padLeft(2, '0')}:${data['expiryDate'].toDate().second.toString().padLeft(2, '0')}'),
                const SizedBox(height: 7),
                const Text('Ưu đãi có hạn'),
                const SizedBox(height: 7),
                const Text('Số lượt dùng tối đa: 1 lần/khách hàng'),
              ],
            ),
          ),
        );
      },
    );
  }
}

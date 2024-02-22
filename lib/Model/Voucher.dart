import 'package:cloud_firestore/cloud_firestore.dart';
class Voucher {
  final String id;
  final String voucherName;
  final String displayName;
  final double discountPercentage;
  final double maxDiscount;
  final double minOrderValue;
  final int maxUses;
  final int currentUses;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isHidden; // Biến mới ẩn voucher , chỉ hiện khi bấm tìm kiếm

  Voucher({
    required this.id,
    required this.voucherName,
    required this.displayName,
    required this.discountPercentage,
    required this.maxDiscount,
    required this.minOrderValue,
    required this.maxUses,
    required this.currentUses,
    required this.startDate,
    required this.expiryDate,
    this.isHidden = false, // Giá trị mặc định cho isHidden là false (không ẩn)
  });

  factory Voucher.fromDocument(DocumentSnapshot doc) {
    return Voucher(
      id: doc.id,
      voucherName: doc['voucherName'],
      displayName: doc['displayName'],
      discountPercentage: doc['discountPercentage'].toDouble(),
      maxDiscount: doc['maxDiscount'].toDouble(),
      minOrderValue: doc['minOrderValue'].toDouble(),
      maxUses: doc['maxUses'],
      currentUses: doc['currentUses'],
      startDate: (doc['startDate'] as Timestamp).toDate(),
      expiryDate: (doc['expiryDate'] as Timestamp).toDate(),
      isHidden: doc['isHidden'] ?? false, // Nếu không có giá trị trong Firestore, giả định là false
    );
  }



}

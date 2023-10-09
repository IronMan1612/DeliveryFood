import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/Voucher.dart';

class VoucherLoader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // 1. Load voucher đã dùng của User
  Future<Set<String>> loadUsedVouchers() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently signed in");
    }

    final String userId = currentUser.uid;

    final voucherSnapshot = await _firestore.collection('users').doc(userId).collection('usedVouchers').get();

    Set<String> localUsedVouchers = Set<String>();

    for (var doc in voucherSnapshot.docs) {
      localUsedVouchers.add(doc.id);
    }

    return localUsedVouchers;
  }


// 2. Load all voucher mặc định

  Future<List<Voucher>> loadVouchers() async {
    final QuerySnapshot querySnapshot = await _firestore.collection('vouchers').get();
    final List<Voucher> vouchers = [];
    for (var doc in querySnapshot.docs) {
      vouchers.add(Voucher.fromDocument(doc));
    }
    return vouchers;
  }


  Future<List<dynamic>> loadAllDataVouchers() async {
    return await Future.wait([
      loadUsedVouchers(),
      loadVouchers(),
    ]);
  }

}

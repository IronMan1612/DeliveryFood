import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/Voucher.dart';
import '../HomeScreen/add_to_Cart.dart';

class CartLogic {
  final BuildContext context;
  CartLogic(this.context);
  final _firestore = FirebaseFirestore.instance;

  double discount = 0.0;
  double totalWithDiscount = 0.0;
  double total = 0.0;

  Map<String, double> updateCartValues(Voucher? selectedVoucher) {
    var cart = Provider.of<Cart>(context, listen: false);
    var items = cart.items;

    // Tính toán tổng giá trị của giỏ hàng
    total = items.entries.fold(0, (prev, e) => prev + (e.key.price * e.value));

    // Tính toán chiết khấu dựa trên voucher nếu có
    if (selectedVoucher != null) {
      double calculatedDiscount = (selectedVoucher.discountPercentage / 100) * total;

      if (calculatedDiscount > selectedVoucher.maxDiscount) {
        calculatedDiscount = selectedVoucher.maxDiscount;
      }

      discount = calculatedDiscount;
    } else {
      discount = 0.0;
    }

    // Tính toán tổng cộng sau khi đã áp dụng voucher
    totalWithDiscount = total - discount;

    return {
      'discount': discount,
      'totalWithDiscount': totalWithDiscount,
      'total': total
    };
  }



  Future<Map<String, dynamic>> isValidVoucher(Voucher voucher) async {
    String message = "";
    final doc = await _firestore.collection('vouchers').doc(voucher.id).get();

    if (!doc.exists) {
      message = "Voucher không tồn tại";
      return {'isValid': false, 'message': message};
    }

    final currentUses = doc.data()?['currentUses'] ?? 0;
    final maxUses = voucher.maxUses;

    if (currentUses >= maxUses) {
      message = "Mã khuyến mãi đã hết lượt sử dụng";
      return {'isValid': false, 'message': message};
    }

    return {'isValid': true, 'message': message};
  }

  void showVoucherAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const  Text("Thông báo",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center),
        content: Text(message , textAlign: TextAlign.center),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextButton(
                  child: const Text('OK', style: TextStyle(color: Colors.orange)),
                  onPressed: () {
                    Navigator.of(ctx).pop();
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

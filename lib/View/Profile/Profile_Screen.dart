import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:lap9/View/Profile/customAction.dart';
import 'package:lap9/View/Profile/personDetails.dart';
import 'package:lap9/View/Profile/user_profile_details.dart';
import 'package:lap9/View/Register/signIn.dart';

import '../Cart/address_screen.dart';
import '../Voucher/Voucher_List_Screen.dart';
import 'Setting.dart';
import 'Support.dart';
import 'aboutUs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          duration: const Duration(seconds: 2),
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
      });
      return const Scaffold();
    }
    return Card(
      child: SafeArea(
        child: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                   PersonDetails(),
                  const SizedBox(
                    height: 15,
                  ),
                  action(
                    icon: Icons.person, // Icon người dùng
                    iconColor: Colors.orange, // Màu cam
                    text: 'Thông tin của tôi',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => UserProfileDetails()),
                      );
                    },
                  ),
                  action(
                    icon: Icons.discount, // Icon người dùng
                    iconColor: Colors.yellow, // Màu cam
                    text: 'Ví voucher',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const VoucherList()),
                      );
                    },
                  ),

                  action(
                    icon: Icons.location_on , // Icon người dùng
                    iconColor: Colors.greenAccent, // Màu cam
                    text: 'Địa chỉ',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AddressPage()),
                      );
                    },
                  ),
                  action(
                    icon: Icons.payment , // Icon người dùng
                    iconColor: Colors.orange, // Màu cam
                    text: 'Thanh toán',
                    onTap: () {
                    },
                  ),
                  action(
                    icon: Icons.settings, // Icon người dùng
                    iconColor: Colors.blue, // Màu cam
                    text: 'Cài đặt',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Setting()),
                      );
                    },
                  ),
                  action(
                    icon: Icons.question_mark_sharp, // Icon người dùng
                    iconColor: Colors.greenAccent, // Màu cam
                    text: 'Trung tâm hỗ trợ',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Support()),
                      );
                    },
                  ),
                  action(
                    icon: Icons.food_bank_outlined, // Icon người dùng
                    iconColor: Colors.orange, // Màu cam
                    text: 'Về chúng tôi',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AboutUs()),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Đăng xuất',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),  // Set text color to white
                            ),
                            content: const Text(
                              'Bạn có muốn đăng xuất?',
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      child: const Text('Đồng ý', style: TextStyle(color: Colors.orange)),
                                      onPressed: () async {
                                        try {
                                          await FirebaseAuth.instance.signOut();
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (contex) => SignIn()));
                                        } catch (error) {
                                          print("Error signing out: $error");
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Error signing out!"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.orange,  // Set background color to orange
                      ),
                      child: const Center(
                        child: Text(
                          'Đăng xuất',
                          style: TextStyle(
                              fontSize: 23,
                              color: Colors.white,  // Set text color to white
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),

                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

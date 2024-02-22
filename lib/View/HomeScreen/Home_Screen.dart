import 'package:DeliveryFood/View/HomeScreen/categoryScreen.dart';
import 'package:DeliveryFood/View/HomeScreen/itemss.dart';
import 'package:DeliveryFood/View/HomeScreen/location.dart';
import 'package:DeliveryFood/View/HomeScreen/titleMenu.dart';
import 'package:flutter/material.dart';

import 'all_Food_Screen.dart';
import 'banner.dart';
import 'nearMe.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        child: SafeArea(
          child: ListView(
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 25),
                      margin: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width,
                      height: null,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xffECF0F1),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                          hintText: 'Search',
                          hintStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    const location(),
                    const BannerWidget(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const AllFoodsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Màu nền của nút
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/food-truck.png',
                              // Replace with your image asset path
                              width: 40, // Adjust the width as needed
                              height: 40, // Adjust the height as needed
                            ),
                            const SizedBox(width: 8),
                            // Add some space between image and text
                            const Text(
                              'Xem Tất Cả Món',
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: null,
                      child: CategoriesScreen(),
                    ),
                    const titlemenu(
                      text: "Food Menu",
                    ),
                    const itemss(),
                    const titlemenu(
                      text: "Near Me",
                    ),
                    const nearmeitem(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

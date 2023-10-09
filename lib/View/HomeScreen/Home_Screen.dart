import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:lap9/View/HomeScreen/category.dart';
import 'package:lap9/View/HomeScreen/itemss.dart';
import 'package:lap9/View/HomeScreen/location.dart';
import 'package:lap9/View/HomeScreen/titleMenu.dart';
import '../../Data/category_list_data.dart';
import 'banner.dart';
import 'nearMe.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 25),
                    margin: const EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    height: 52,
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
                  const SizedBox(width: 10 , height: 5),
                  BannerWidget(), // Thêm banner
                  const SizedBox(width: 5),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    height: 150.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return CategoryWidget(foodCategory: categories[index]);
                      },
                    ),
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
    );

  }
}

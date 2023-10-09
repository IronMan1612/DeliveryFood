import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Model/food_category.dart';
import '../../Services/Firebase_Service.dart';
import 'category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... (Các thuộc tính khác của Scaffold)
      body: FutureBuilder<List<FoodCategory>>(
        future: _firebaseService.fetchCategoriesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Nếu dữ liệu đang được tải, hiển thị màn hình loading
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Nếu có lỗi, hiển thị thông báo lỗi
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Nếu không có dữ liệu, hiển thị thông báo không có dữ liệu
            return Center(child: Text('Không có dữ liệu.'));
          } else {
            // Nếu có dữ liệu, hiển thị danh sách
            List<FoodCategory> categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryWidget(foodCategory: categories[index]);
              },
            );
          }
        },
      ),
    );
  }
}

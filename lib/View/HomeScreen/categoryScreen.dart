import 'package:flutter/material.dart';
import '../../Model/food_category.dart';
import '../../Services/Firebase_Service.dart';
import 'category.dart';

class CategoriesScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  CategoriesScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FoodCategory>>(
      future: _firebaseService.fetchCategoriesData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.fastfood, size: 50, color: Colors.orange),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu.'));
        } else {
          List<FoodCategory> categories = snapshot.data!;
          return Wrap(
            spacing: 0.0,
            runSpacing: 0.0,
            alignment: WrapAlignment.start, // Đặt alignment để bắt đầu từ trái qua phải
            children: categories.map((category) {
              return CategoryWidget(foodCategory: category);
            }).toList(),
          );

        }
      },
    );
  }
}

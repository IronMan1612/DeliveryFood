import 'package:flutter/material.dart';
import 'package:lap9/Model/food_category.dart';
import 'package:lap9/Services/firebase_service.dart';
import 'food_list_screen.dart';

class CategoryWidget extends StatelessWidget {
  final FoodCategory foodCategory;
  final FirebaseService _firebaseService = FirebaseService();

  CategoryWidget({required this.foodCategory});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodListScreen(categoryId: foodCategory.id),

          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xffECF0F1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(foodCategory.imagePath),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              foodCategory.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:DeliveryFood/Model/food_category.dart';
import 'food_list_screen.dart';

class CategoryWidget extends StatelessWidget {
  final FoodCategory foodCategory;

  const CategoryWidget({super.key, required this.foodCategory});

  Widget _getImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        height: 50,
        width: 50,
          fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: 50,
          height: 50,
          color: Colors.white, // Màu nền, có thể thay đổi theo ý muốn
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return Image.asset(
        imagePath,
        height: 50,
        width: 50,
          fit: BoxFit.contain
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hàm này trả về widget hình ảnh dựa trên URL

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
        width: 100,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: _getImage(foodCategory.imagePath),  // Sử dụng hàm _getImage
            ),
            Text(
              foodCategory.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

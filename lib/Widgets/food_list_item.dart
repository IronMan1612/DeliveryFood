import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/food_item.dart';
import '../View/HomeScreen/add_to_Cart.dart';
import 'food_detail_screen.dart';

class FoodListItem extends StatelessWidget {
  final FoodItem food;

  FoodListItem({required this.food});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<Cart>(context);
    double maxHeight = MediaQuery.of(context).size.height;

    return Opacity(
      opacity: food.isAvailable ? 1.0 : 0.5,
      // Điều chỉnh độ mờ dựa trên trạng thái của món ăn
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          leading: Image.asset(food.imagePath, width: 60, fit: BoxFit.cover),
          title: Text(food.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                food.description.length > 20
                    ? food.description.substring(0, 20) + '...'
                    : food.description,
              ),
              const SizedBox(height: 10),
              Text(
                '${food.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              SizedBox(height: maxHeight,),
              if (food != null &&
                  cart.items.containsKey(food) &&
                  cart.items[food]! > 0)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: SizedBox(
                    width: 30,  // Điều chỉnh theo mong muốn của bạn
                    height: 30, // Điều chỉnh theo mong muốn của bạn
                    child: IconButton(
                      padding: EdgeInsets.zero, // set padding bằng 0
                      iconSize: 15,
                      icon: const Icon(Icons.remove, color: Colors.orange),
                      onPressed: () {
                        cart.removeFromCart(food);
                      },
                    ),
                  ),
                ),
              const SizedBox(width: 15),
              if (food != null &&
                  cart.items.containsKey(food) &&
                  cart.items[food]! > 0)
                Text(
                  '${cart.items[food]}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(width: 15),
              if (food != null && food.isAvailable)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: SizedBox(
                    width: 30,  // Điều chỉnh theo mong muốn của bạn
                    height: 30, // Điều chỉnh theo mong muốn của bạn
                    child: IconButton(
                      padding: EdgeInsets.zero, // set padding bằng 0
                      iconSize: 15,
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        cart.addToCart(food);
                      },
                    ),
                  ),
                ),

              if (food != null && !food.isAvailable)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacer(),
                    Text(
                      'Hết món',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                    // Đặt giá tiền ở đây
                  ],
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(food: food),
              ),
            );
          },
        ),
      ),
    );
  }
}

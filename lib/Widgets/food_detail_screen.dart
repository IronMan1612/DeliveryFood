import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/food_item.dart';
import '../View/HomeScreen/add_to_Cart.dart';
class FoodDetailScreen extends StatelessWidget {
  final FoodItem food;

  FoodDetailScreen({required this.food});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(food.name, style: const TextStyle(color: Colors.white)),
      ),
      body: Opacity(
        opacity: food.isAvailable ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                food.imagePath,
                                fit: BoxFit.contain,
                                height: MediaQuery.of(ctx).size.height * 0.8,
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 30, color: Colors.white),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Image.asset(
                    food.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(food.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (!food.isAvailable)
                    const Text(
                      'Hết món',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${food.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(food.description),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cart.items.containsKey(food) && cart.items[food]! > 0)
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.orange),
                      onPressed: () {
                        cart.removeFromCart(food);
                      },
                    ),
                  const SizedBox(width: 15),
                  if (cart.items.containsKey(food) && cart.items[food]! > 0)
                    Text(
                      '${cart.items[food]}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(width: 15),
                  if (food.isAvailable)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          cart.addToCart(food);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

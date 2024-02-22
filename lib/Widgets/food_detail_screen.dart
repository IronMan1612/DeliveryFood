import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/food_item.dart';
import '../View/HomeScreen/add_to_Cart.dart';
class FoodDetailScreen extends StatelessWidget {
  final FoodItem food;

   const FoodDetailScreen({super.key, required this.food});



  Widget _loadImage(String imagePath, {BoxFit? fit, double? height}) {
    Widget imageWidget;
    if (imagePath.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        placeholder: (context, url) => Container(
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: fit ?? BoxFit.contain, // Sử dụng giá trị mặc định nếu không được cung cấp
        height: height,
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
        fit: fit ?? BoxFit.contain, // Sử dụng giá trị mặc định nếu không được cung cấp
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        width: double.infinity, //height do ảnh tự lấy
        color: Colors.white,
        child: imageWidget,
      ),
    );
  }


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
              SizedBox(
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
                              child: _loadImage(
                                food.imagePath,
                                fit: BoxFit.contain, // hoặc BoxFit.cover tùy vào trường hợp
                                height: MediaQuery.of(ctx).size.height * 0.8, // hoặc giá trị khác tùy vào trường hợp
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
                  child: _loadImage(
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

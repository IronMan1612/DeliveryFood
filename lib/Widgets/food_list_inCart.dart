import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../Model/food_item.dart';
import '../View/HomeScreen/add_to_Cart.dart';

class FoodListCart extends StatefulWidget {
  final Map<FoodItem, int> items;
  final Cart cart;

  final Function onCartChanged;

  const FoodListCart({super.key, required this.items, required this.cart, required this.onCartChanged});


  @override
  _FoodListCartState createState() => _FoodListCartState();
}

class _FoodListCartState extends State<FoodListCart> {
  final Map<String, TextEditingController> _noteControllers = {};
  bool expandedView = false;

  Widget _loadImage(String imagePath) {
    Widget imageWidget;
    if (imagePath.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        placeholder: (context, url) => Container(
          width: 80,
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
          width: 80, fit: BoxFit.cover
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
          width: 80, fit: BoxFit.cover
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        width: 80,
        color: Colors.white,
        child: imageWidget,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> displayList = [];
    if (expandedView || widget.items.length <= 2) {
      displayList.addAll(widget.items.keys.map((food) => _foodItemWidget(food)).toList());


    } else {
      displayList.addAll(widget.items.keys.take(2).map((food) => _foodItemWidget(food)).toList());
      displayList.add(
        TextButton(
          onPressed: () {
            setState(() {
              expandedView = true;
            });
          },
          child: const Text("Xem thêm"),
        ),
      );
    }

    if (expandedView && widget.items.length > 2) {
      displayList.add(
        TextButton(
          onPressed: () {
            setState(() {
              expandedView = false;
            });
          },
          child: const Text("Thu gọn"),
        ),
      );
    }

    return Column(children: displayList);
  }

  Widget _foodItemWidget(FoodItem food) {
    return Card(
      child: ListTile(
        leading: _loadImage(food.imagePath),
        title: Text(food.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${food.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ x ${widget.items[food]}",
              style:
              const TextStyle(color: Colors.orange),
            ),
            Text(
              "Ghi chú: ${food.note ?? ''}",
              style:
              const TextStyle(color: Colors.black87),
            ),
            SizedBox(
              height: 24,
              child: TextField(
                controller: _noteControllers[food.id],
                onChanged: (newNote) {
                  widget.cart.updateNoteForFood(food, newNote);
                },
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 4, horizontal: 8),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.remove,
                  color: Colors.orange),
              onPressed: () {
                if (widget.items[food] == 1) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Xác nhận",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center),
                      content: const Text(
                        "Bạn có muốn xoá món ra khỏi giỏ hàng?",
                        textAlign: TextAlign.center,),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextButton(
                                child: const Text('Huỷ', style: TextStyle(color: Colors.black)),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                child: const Text("OK", style: TextStyle(color: Colors.orange)),
                                onPressed: () {
                                  widget.cart.removeFromCart(food);
                                  widget.items.remove(food);
                                  Navigator.of(ctx).pop();
                                  widget.onCartChanged();
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  widget.cart.removeFromCart(food);
                  widget.onCartChanged();

                }
              },
            ),
            Text('${widget.items[food]}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add,
                  color: Colors.orange),
              onPressed: () {
                widget.cart.addToCart(food);
                widget.onCartChanged();

              },
            ),
          ],
        ),
      ),
    );
  }
}

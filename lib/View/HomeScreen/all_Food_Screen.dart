import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/food_item.dart';
import '../../Widgets/food_list_item.dart';
import '../Cart/Cart_Screen.dart';
import 'add_to_Cart.dart';
import '../../Services/Firebase_Service.dart';

class AllFoodsScreen extends StatefulWidget {
  const AllFoodsScreen({Key? key}) : super(key: key);

  @override
  _AllFoodsScreenState createState() => _AllFoodsScreenState();
}

class _AllFoodsScreenState extends State<AllFoodsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<FoodItem>> foodStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  _initStream() {
    _searchController.addListener(_onSearchChanged);
    foodStream = FirebaseService().getAllFoods().asStream();
  }

  _onSearchChanged() async {
    String searchQuery = _searchController.text.replaceAll(' ', '').toLowerCase();
    List<FoodItem> newFoodList;

    if (searchQuery.isEmpty) {
      newFoodList = await FirebaseService().getAllFoods();
    } else {
      newFoodList = (await FirebaseService().getAllFoods())
          .where((food) => food.searchName.contains(searchQuery))
          .toList();
    }

    setState(() {
      foodStream = Stream.value(newFoodList);
    });
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Tìm món...",
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: _searchController.text.trim().isEmpty
                ? null
                : IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _initStream();
                });
              },
            ),
          ),
        ),
        actions: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              IconButton(
                padding: const EdgeInsets.only(right: 15.0),
                icon: const Icon(
                  Icons.shopping_cart,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    child: Text(
                      '${cart.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // tắt bàn phím
          FocusScope.of(context).unfocus();
        },
        child: StreamBuilder<List<FoodItem>>(
          stream: foodStream,
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
            }
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text("Có lỗi xảy ra!"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Không có món ăn nào!",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              );
            }
            List<FoodItem> foods = snapshot.data!;

            return ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, index) {
                return FoodListItem(food: foods[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

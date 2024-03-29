import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/food_item.dart';
import '../../Widgets/food_list_item.dart';
import '../Cart/Cart_Screen.dart';
import 'add_to_Cart.dart';

class FoodListScreen extends StatefulWidget {
  final String categoryId;

  const FoodListScreen({super.key, required this.categoryId});

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> foodStream;

  @override
  void initState() {
    super.initState();
    Provider.of<Cart>(context, listen: false).loadCart();
    _searchController.addListener(_onSearchChanged);
    _initStream();
  }

  _initStream() {
      foodStream = FirebaseFirestore.instance
          .collection('foods')
          .where('category', isEqualTo: widget.categoryId)
          .snapshots();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() async {
    String searchQuery = _searchController.text.replaceAll(' ', '').toLowerCase();
    Stream<QuerySnapshot<Map<String, dynamic>>> newFoodStream;

    if (searchQuery.isEmpty) {
      _initStream();              // trả về list món ban đầu nếu xoá tìm kiếm
      setState(() {});
      return;
    } else {
      newFoodStream = FirebaseFirestore.instance
          .collection('foods')
          .where('category', isEqualTo: widget.categoryId)
          .where('searchName', arrayContains: searchQuery)
          .snapshots();
      /*
      bool isEmpty = await newFoodStream.isEmpty;

      if (isEmpty) {
        newFoodStream = FirebaseFirestore.instance
            .collection('foods')
            .where('category', isEqualTo: widget.categoryId)
            .orderBy('searchName')
            .startAt([searchQuery])
            .endAt([searchQuery + '\uf8ff'])
            .snapshots();
      }

       */
    }

    setState(() {
      foodStream = newFoodStream;
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
               /* onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const NavBar(
                            initialPage: 1)),
                    // 1 là index của CartScreen // Xóa tất cả các màn hình trước đó
                  );
                },

                */

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
        child: StreamBuilder<QuerySnapshot>(
          stream: foodStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text("Có lỗi xảy ra!"));
            }
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
            List<FoodItem> foods = snapshot.data!.docs.map((doc) {
              var data = doc.data()! as Map<String, dynamic>;
              return FoodItem.fromMap({
                ...data,
                'id': doc.id // Pass the unique Firebase document ID here
              });
            }).toList();

            if (foods.isEmpty) {
              return const Center(
                child: Text(
                  "Món này chưa bán",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              );
            }
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

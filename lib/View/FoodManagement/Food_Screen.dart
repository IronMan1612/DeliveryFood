import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/food_provider.dart';

import '../../Model/food_item.dart';
import 'AddFood.dart';
import 'EditFood.dart';

class FoodManagementScreen extends StatefulWidget {
  const FoodManagementScreen({Key? key}) : super(key: key);

  @override
  _FoodManagementScreenState createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen> {
  Future<void> _refreshData() async {
    print("Refresh Data Context: $context");
    await Provider.of<FoodProvider>(context, listen: false).fetchFoodsByCategory();
  }

  @override
  void initState() {
    super.initState();
    Provider.of<FoodProvider>(context, listen: false).fetchFoodsByCategory();
  }


  Widget _loadImage(String imagePath) {
    Widget imageWidget;
    if (imagePath.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.contain,
      );
    } else {
      imageWidget = Image.asset(imagePath, fit: BoxFit.contain);
    }

    return ClipRRect(
      child: Container(
        width: 80,
        height: 80,
        color: Colors.white,
        child: imageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý món ăn"),
        backgroundColor: Colors.orange,
      ),
      body: Card(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Consumer<FoodProvider>(
            builder: (context, foodProvider, _) {
              if (foodProvider.isLoading) {
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
              } else if (foodProvider.hasError) {
                print("Error: ${foodProvider.error}");
                return Center(child: Text('Lỗi: ${foodProvider.error}'));
              } else if (foodProvider.foodsByCategory.isEmpty) {
                return const Center(child: Text('Không có dữ liệu.'));
              } else {
                Map<String, List<FoodItem>> foodsByCategory =
                    foodProvider.foodsByCategory;
                return ListView(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  children: foodsByCategory.entries.map<Widget>((entry) {
                    String categoryName = entry.key;
                    List<FoodItem> foods = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(thickness: 2),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(categoryName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        if (foods.isNotEmpty)
                          ...foods
                              .map((food) => Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Opacity(
                              opacity: food.isAvailable ? 1.0 : 0.5,
                              child: ListTile(
                                leading: _loadImage(food.imagePath),
                                title: Text("ID ${food.id}"),
                                subtitle: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(food.name),
                                    Text(
                                      '${food.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                                      style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.orange),
                                      onPressed: () async {
                                        FoodItem editedFood =
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditFood(food: food),
                                          ),
                                        );
                                        Provider.of<FoodProvider>(context, listen: false)
                                            .setFood(editedFood);
                                        await _refreshData();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                                "Xác nhận",
                                                textAlign:
                                                TextAlign.center),
                                            content: RichText(
                                              textAlign:
                                              TextAlign.center,
                                              text: TextSpan(
                                                style: DefaultTextStyle
                                                    .of(context)
                                                    .style,
                                                children: <TextSpan>[
                                                  const TextSpan(
                                                      text:
                                                      "Bạn sẽ xóa món ",
                                                      style: TextStyle(
                                                          fontSize:
                                                          15)),
                                                  TextSpan(
                                                      text: food.name,
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors
                                                              .orange)),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                                children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      child: const Text(
                                                          "Hủy",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                      onPressed: () {
                                                        Navigator.of(
                                                            ctx)
                                                            .pop();
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: TextButton(
                                                      child: const Text(
                                                        "Xóa",
                                                        style: TextStyle(color: Colors.orange),
                                                      ),
                                                      onPressed: () async {
                                                        try {
                                                          Provider.of<FoodProvider>(context, listen: false).deleteFood(food.id);
                                                          Navigator.of(ctx).pop();
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                            content: Text('Xóa thành công'),
                                                            backgroundColor: Colors.green,
                                                            duration: Duration(seconds: 1),
                                                          ));
                                                        } catch (e) {
                                                          print("Error deleting food: $e");
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                            content: Text('Lỗi khi xóa món ăn'),
                                                            backgroundColor: Colors.red,
                                                            duration: Duration(seconds: 1),
                                                          ));
                                                        }
                                                      },
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                              .toList(),
                        if (foods.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text("Danh mục trống",
                                style: TextStyle(color: Colors.red)),
                          )
                      ],
                    );
                  }).toList(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          FoodItem? newFood = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFood(),
            ),
          );
          if (newFood != null) {
            Provider.of<FoodProvider>(context, listen: false).addFood(newFood);
            await _refreshData();
          }
        },
      ),
    );
  }
}

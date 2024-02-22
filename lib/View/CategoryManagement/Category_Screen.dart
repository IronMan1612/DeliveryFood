import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/food_category.dart';
import '../../Model/food_item.dart';
import '../../Provider/category_provider.dart';
import '../../Services/Firebase_Service.dart';
import 'AddCategory.dart';
import 'EditCategory.dart';


class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  _CategoryManagementScreenState createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  late CategoryProvider _categoryProvider;

  @override
  void initState() {
    super.initState();
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _categoryProvider.fetchData();
  }
  Future<bool> _isEmptyCategory(FoodCategory category) async {
    // Kiểm tra xem danh mục có trống không
    Map<String, List<FoodItem>> foodsByCategory = await FirebaseService().fetchFoodsByCategory();
    return foodsByCategory.containsKey(category.name) && foodsByCategory[category.name]!.isEmpty;
  }
  void _deleteCategory(BuildContext ctx, FoodCategory category) {
    showDialog(
      context: ctx,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Xác nhận", textAlign: TextAlign.center),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(ctx).style,
              children: <TextSpan>[
                const TextSpan(text: "Bạn sẽ xóa danh mục ", style: TextStyle(fontSize: 15)),
                TextSpan(text: category.name, style: const TextStyle(fontSize: 15, color: Colors.orange)),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    child: const Text("Hủy", style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    child: const Text("Xóa", style: TextStyle(color: Colors.orange)),
                    onPressed: () async {
                      bool isEmptyCategory = await _isEmptyCategory(category);

                      if (isEmptyCategory) {
                        try {
                          await FirebaseService().deleteCategory(category.id);
                          _categoryProvider.fetchData();

                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('Xóa thành công'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ));
                        } catch (e) {
                          print("Error deleting category: $e");
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('Lỗi khi xóa danh mục'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                          content: Text('Chỉ được xóa danh mục trống'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 1),
                        ));
                      }
                      Navigator.of(ctx).pop();
                    },

                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý danh mục"),
        backgroundColor: Colors.orange,
      ),
      body: Card(
        child: RefreshIndicator(
          onRefresh: () async {
            await _categoryProvider.fetchData();
          },
          child: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.categories == null) {
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
              } else if (categoryProvider.categories!.isEmpty) {
                return const Center(child: Text('Không có dữ liệu.'));
              } else {
                return _buildCategoryList(categoryProvider.categories!);
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
          ).then((newCategory) {
            if (newCategory != null) {
              _categoryProvider.fetchData();
            }
          });
        },
      ),
    );
  }

  Widget _buildCategoryList(List<FoodCategory> categories) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 60.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: _loadImage(categories[index].imagePath),
          title: Text("ID: ${categories[index].id}"),
          subtitle: Text(categories[index].name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditCategory(category: categories[index])),
                  ).then((updatedCategory) {
                    if (updatedCategory != null) {
                      _categoryProvider.fetchData();
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteCategory(context, categories[index]);
                },
              ),
            ],
          ),
        );
      },
    );
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
        width: 80, // width of the square
        height: 80, // height of the square
        color: Colors.white, // background color, can be used as a placeholder
        child: imageWidget,
      ),
    );
  }
}
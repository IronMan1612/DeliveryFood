import '../Model/food_category.dart';
import 'food_list_data.dart';

List<FoodCategory> categories = [
  FoodCategory(
    id: '1',
    name: 'Món ăn',
    imagePath: 'assets/burger.png',
    foods: foodsForCategory1.map((food) => food.id).toList(),
  ),
  FoodCategory(
    id: '2',
    name: 'Đồ uống',
    imagePath: 'assets/drink.png',
    foods: foodsForCategory2.map((food) => food.id).toList(),
  ),
  FoodCategory(
    id: '3',
    name: 'Tráng miệng',
    imagePath: 'assets/cake.png',
    foods: foodsForCategory3.map((food) => food.id).toList(),
  ),
  // ... (các danh mục khác)
];

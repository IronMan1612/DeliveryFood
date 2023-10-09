import '../Model/food_category.dart';
import 'food_list_data.dart';

List<FoodCategory> categories = [
  FoodCategory(
    id: '1',
    name: 'Món ăn',
    imagePath: 'assets/burger (1) 1.png',
    foods: foodsForCategory1.map((food) => food.id).toList(),
  ),
  FoodCategory(
    id: '2',
    name: 'Đồ uống',
    imagePath: 'assets/coffee-cup 1.png',
    foods: foodsForCategory2.map((food) => food.id).toList(),
  ),
  FoodCategory(
    id: '3',
    name: 'Tráng miệng',
    imagePath: 'assets/piece-of-cake 1.png',
    foods: foodsForCategory3.map((food) => food.id).toList(),
  ),
  // ... (các danh mục khác)

  FoodCategory(
    id: 'all',
    name: 'Tất cả các món',
    imagePath: 'assets/potato-chips 1.png',
    foods: allFoods.map((food) => food.id).toList(),
  ),
];

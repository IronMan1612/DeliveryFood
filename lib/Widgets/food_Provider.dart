import 'package:flutter/cupertino.dart';

import '../Model/food_item.dart';

class AllFoodsProvider extends ChangeNotifier {
  List<FoodItem> allFoods = [];

  void setAllFoods(List<FoodItem> newFoods) {
    allFoods = newFoods;
    notifyListeners();
  }
}
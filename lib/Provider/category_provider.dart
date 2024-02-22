import 'package:flutter/material.dart';
import '../Model/food_category.dart';
import '../Services/Firebase_Service.dart';

class CategoryProvider extends ChangeNotifier {
  List<FoodCategory>? _categories;

  List<FoodCategory>? get categories => _categories;

  Future<void> fetchData() async {
    _categories = await FirebaseService().fetchCategoriesData();
    notifyListeners();
  }
  
}
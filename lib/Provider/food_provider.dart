import 'package:flutter/material.dart';
import '../../Model/food_item.dart';
import '../../Services/Firebase_Service.dart';

class FoodProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  late Map<String, List<FoodItem>> _foodsByCategory;
  bool _isLoading = false;
  String _error = '';

  // Hàm để fetch dữ liệu món ăn theo danh mục
  Future<void> fetchFoodsByCategory() async {
    try {
      _isLoading = true;
      _error = '';
      _foodsByCategory = await _firebaseService.fetchFoodsByCategory();
    } catch (error) {
      _error = 'Error fetching data: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFood(FoodItem food) async {
    try {
      // Add your logic to add a new food item
      await _firebaseService.setFood(food);
      // Update _foodsByCategory accordingly
      await fetchFoodsByCategory();
    } catch (error) {
      print('Error adding food: $error');
    }
  }

  Future<void> setFood(FoodItem food) async {
    try {
      // Add your logic to update an existing food item
      await _firebaseService.setFood(food);
      // Update _foodsByCategory accordingly
      await fetchFoodsByCategory();
    } catch (error) {
      print('Error updating food: $error');
    }
  }

  // Hàm để xóa món ăn
  Future<void> deleteFood(String foodId) async {
    try {
      _isLoading = true;
      _error = '';

      // Gọi hàm xóa món ăn từ FirebaseService
      await _firebaseService.deleteFood(foodId);

      // Cập nhật _foodsByCategory sau khi xóa
      await fetchFoodsByCategory();
    } catch (error) {
      _error = 'Error deleting food: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  bool get hasError => _error.isNotEmpty;
  String get error => _error;
  Map<String, List<FoodItem>> get foodsByCategory => _foodsByCategory;
}

class FoodCategory {
  final String id;
  final String name;
  final String imagePath;
  final List<String> foods; // danh sách các ID thực phẩm thuộc danh mục

  FoodCategory({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.foods,
  });

  // Phương thức fromMap để chuyển đổi từ Map sang FoodCategory
  static FoodCategory fromMap(Map<String, dynamic> map) {
    return FoodCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imagePath: map['imagePath'] ?? '',
      foods: List<String>.from(map['foods'] ?? []),
    );
  }
}

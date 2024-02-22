class FoodItem {
  final String id;
  final String name;
  final List<String> searchName;
  String? note;
  final String description;
  final double price;
  final String imagePath;
  final String category;
  final bool isAvailable;
  int quantity;

  FoodItem({
    required this.id,
    required this.name,
    this.note,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.isAvailable,
    this.quantity = 0,
  }) : searchName = generateKeywords(name);

  void decrement() {
    if (quantity > 0) {
      quantity--;
    }
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? note,
    String? description,
    double? price,
    String? imagePath,
    String? category,
    bool? isAvailable,
    int? quantity,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      quantity: quantity ?? this.quantity,
    );
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      note: map['note'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      imagePath: map['imagePath'],
      category: map['category'],
      isAvailable: map['isAvailable'] ?? true,
      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'searchName': searchName,
      'note': note,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'category': category,
      'isAvailable': isAvailable,
      'quantity': quantity,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FoodItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<String> generateKeywords(String name) {
    List<String> result = [];
    var splitWords = name.split(' ');               // tách từ thành chuỗi từ đơn
    for (int i = 0; i < splitWords.length; i++) {
      for (int j = i; j < splitWords.length; j++) {
        result.add(concatenateWords(splitWords, i, j).toLowerCase());
      }
    }
    return result;
  }

  static String concatenateWords(List<String> words, int start, int end) {
    String result = "";
    for (int i = start; i <= end; i++) {                          // ghép từ đơn lại
      result += words[i];
    }
    return result;
  }
}

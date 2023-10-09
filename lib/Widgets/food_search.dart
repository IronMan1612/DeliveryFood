import 'package:flutter/material.dart';

import '../Model/food_item.dart';

class FoodSearch extends SearchDelegate<FoodItem?> {
  final List<FoodItem> foods;

  FoodSearch({required this.foods});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      title: Text("Select one of the suggestions."),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = foods.where((food) {
      return food.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () => close(context, suggestions[index]),
          title: Text(suggestions[index].name),
        );
      },
    );
  }
}

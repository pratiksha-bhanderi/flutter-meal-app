import 'package:flutter/material.dart';

class FavouritesProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _favouriteMeals = [];

  List<Map<String, dynamic>> get favouriteMeals => [..._favouriteMeals];

  bool isFavourite(String mealName) {
    return _favouriteMeals.any((meal) => meal['name'] == mealName);
  }

  void toggleFavourite(Map<String, dynamic> meal) {
    final index = _favouriteMeals.indexWhere((m) => m['name'] == meal['name']);
    if (index >= 0) {
      _favouriteMeals.removeAt(index);
    } else {
      _favouriteMeals.add(meal);
    }
    notifyListeners();
  }

  int get favouriteCount => _favouriteMeals.length;
}

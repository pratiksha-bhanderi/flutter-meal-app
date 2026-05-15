import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _deals = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get meals => _meals;
  List<Map<String, dynamic>> get deals => _deals;
  bool get isLoading => _isLoading;

  DataProvider() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      debugPrint('DataProvider: Starting to load data...');
      _isLoading = true;
      notifyListeners();

      // Load Meals
      try {
        final String mealsString = await rootBundle.loadString('assets/data/meals.json');
        final List<dynamic> mealsJson = json.decode(mealsString);
        _meals = mealsJson.map((m) => Map<String, dynamic>.from(m)).toList();
        debugPrint('DataProvider: Loaded ${_meals.length} meals from JSON');
      } catch (e) {
        debugPrint('DataProvider: Failed to load meals.json, using fallback. Error: $e');
        _meals = _fallbackMeals;
      }

      // Load Deals
      try {
        final String dealsString = await rootBundle.loadString('assets/data/deals.json');
        final List<dynamic> dealsJson = json.decode(dealsString);
        _deals = dealsJson.map((d) => Map<String, dynamic>.from(d)).toList();
        debugPrint('DataProvider: Loaded ${_deals.length} deals from JSON');
      } catch (e) {
        debugPrint('DataProvider: Failed to load deals.json, using fallback. Error: $e');
        _deals = _fallbackDeals;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('DataProvider: Critical error in loadData: $e');
      debugPrint('DataProvider: Stack trace: $stack');
      _isLoading = false;
      notifyListeners();
    }
  }

  static const _fallbackMeals = [
    {'name': 'Margherita Pizza', 'price': '\$12.99', 'calories': '250', 'category': 'Pizza', 'image': 'assets/images/meals/pizza.png'},
    {'name': 'Classic Burger', 'price': '\$9.99', 'calories': '450', 'category': 'Burgers', 'image': 'assets/images/meals/burger.png'},
  ];

  static const _fallbackDeals = [
    {'name': 'Double Burger Combo', 'price': '\$15.99', 'oldPrice': '\$22.00', 'image': 'assets/images/meals/burger.png', 'off': '30% OFF'},
  ];

  List<Map<String, dynamic>> getMealsByCategory(String category) {
    if (category == 'All') return _meals;
    return _meals.where((m) => m['category'] == category).toList();
  }
}

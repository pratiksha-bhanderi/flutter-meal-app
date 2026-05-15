import 'package:flutter/material.dart';

class HistoryProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _recentlyViewed = [];

  List<Map<String, dynamic>> get recentlyViewed => List.unmodifiable(_recentlyViewed);

  void addToRecentlyViewed(Map<String, dynamic> meal) {
    // Remove if already exists to move it to the front
    _recentlyViewed.removeWhere((item) => item['name'] == meal['name']);
    
    // Add to the front
    _recentlyViewed.insert(0, meal);
    
    // Keep only last 5 items
    if (_recentlyViewed.length > 5) {
      _recentlyViewed.removeLast();
    }
    
    notifyListeners();
  }
}

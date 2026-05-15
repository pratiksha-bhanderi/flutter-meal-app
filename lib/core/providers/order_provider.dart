import 'package:flutter/material.dart';
import 'package:meal_app/core/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _pastOrders = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get pastOrders => _pastOrders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    
    _pastOrders = await _orderService.loadOrders();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> placeOrder(List<Map<String, dynamic>> items, double total) async {
    final newOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'items': items,
      'total': total,
      'status': 'Delivered', // Default for history
    };

    await _orderService.saveOrder(newOrder);
    await loadOrders();
  }

  Future<void> clearHistory() async {
    await _orderService.clearOrders();
    _pastOrders = [];
    notifyListeners();
  }
}

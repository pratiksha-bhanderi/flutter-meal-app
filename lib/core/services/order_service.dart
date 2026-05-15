import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String _ordersKey = 'past_orders';

  Future<void> saveOrder(Map<String, dynamic> order) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existingOrders = prefs.getStringList(_ordersKey) ?? [];
    
    // Add new order to the beginning of the list
    existingOrders.insert(0, json.encode(order));
    
    await prefs.setStringList(_ordersKey, existingOrders);
  }

  Future<List<Map<String, dynamic>>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ordersJson = prefs.getStringList(_ordersKey) ?? [];
    
    return ordersJson.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'meal_app_cart';

  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(cartItems);
    await prefs.setString(_cartKey, encodedData);
  }

  Future<List<Map<String, dynamic>>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_cartKey);
    if (encodedData != null) {
      final List<dynamic> decodedData = json.decode(encodedData);
      return decodedData.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}

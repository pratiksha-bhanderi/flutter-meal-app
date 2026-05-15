import 'package:flutter/material.dart';
import 'package:meal_app/core/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  int get itemCount {
    int count = 0;
    for (var item in _items) {
      count += (item['quantity'] as int);
    }
    return count;
  }

  double get subtotal {
    double total = 0;
    for (var item in _items) {
      final priceStr = item['price']?.replaceAll('\$', '') ?? '0';
      total += (double.tryParse(priceStr) ?? 0) * (item['quantity'] as int);
    }
    return total;
  }

  double get deliveryFee => _items.isEmpty ? 0.0 : 2.50;

  double get total => subtotal + deliveryFee;

  CartProvider() {
    _initCart();
  }

  Future<void> _initCart() async {
    _items = await _cartService.loadCart();
    notifyListeners();
  }

  Future<void> addToCart(Map<String, dynamic> meal) async {
    final existingIndex = _items.indexWhere((item) => item['name'] == meal['name']);
    if (existingIndex >= 0) {
      _items[existingIndex]['quantity'] = (_items[existingIndex]['quantity'] as int) + 1;
    } else {
      _items.add({
        'name': meal['name'],
        'price': meal['price'],
        'image': meal['image'],
        'quantity': 1,
      });
    }
    await _cartService.saveCart(_items);
    notifyListeners();
  }

  Future<void> updateQuantity(int index, int delta) async {
    _items[index]['quantity'] = (_items[index]['quantity'] as int) + delta;
    if (_items[index]['quantity'] < 1) {
      _items.removeAt(index);
    }
    await _cartService.saveCart(_items);
    notifyListeners();
  }

  Future<void> removeItem(int index) async {
    _items.removeAt(index);
    await _cartService.saveCart(_items);
    notifyListeners();
  }

  int getItemQuantity(String name) {
    final index = _items.indexWhere((item) => item['name'] == name);
    return index >= 0 ? (_items[index]['quantity'] as int) : 0;
  }

  int getItemIndex(String name) {
    return _items.indexWhere((item) => item['name'] == name);
  }

  Future<void> clearCart() async {
    _items = [];
    await _cartService.clearCart();
    notifyListeners();
  }
}

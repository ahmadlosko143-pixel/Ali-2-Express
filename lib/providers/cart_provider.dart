import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get isEmpty => _items.isEmpty;

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');

      if (cartData != null) {
        final List<dynamic> jsonData = json.decode(cartData);
        _items = jsonData.map((json) => CartItem.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(
        _items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('cart', jsonData);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Product already in cart, increase quantity
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new product to cart
      _items.add(CartItem(product: product, quantity: quantity));
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (quantity <= 0) {
        // Remove if quantity is 0 or negative
        _items.removeAt(index);
      } else if (quantity <= 10) {
        // Update quantity (max 10)
        _items[index].quantity = quantity;
      }
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    try {
      final item = _items.firstWhere((item) => item.product.id == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}

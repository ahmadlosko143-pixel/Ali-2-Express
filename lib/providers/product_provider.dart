import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

/// Provider for managing products and admin operations
class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Get unique categories from products
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.insert(0, 'All');
    return cats;
  }

  /// Load products from local JSON file
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First, try to load from SharedPreferences (for admin-added products)
      final prefs = await SharedPreferences.getInstance();
      final savedProducts = prefs.getString('products');
      final bool needsReset = prefs.getBool('products_reset_needed') ?? true;

      // If reset is needed or no saved products, load from assets
      if (needsReset || savedProducts == null) {
        await _loadFromAssets();
        await prefs.setBool('products_reset_needed', false);
      } else {
        final List<dynamic> jsonData = json.decode(savedProducts);
        _products = jsonData.map((json) => Product.fromJson(json)).toList();
      }

      _filteredProducts = _products;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _products = [];
      _filteredProducts = [];
      notifyListeners();
      debugPrint('Error loading products: $e');
    }
  }

  /// Load products from assets JSON file
  Future<void> _loadFromAssets() async {
    final String response = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final List<dynamic> jsonData = json.decode(response);
    _products = jsonData.map((json) => Product.fromJson(json)).toList();
    await _saveProducts();
  }

  /// Reset products to default from assets
  Future<void> resetToDefaults() async {
    await _loadFromAssets();
    _filteredProducts = _products;
    notifyListeners();
  }

  /// Save products to SharedPreferences
  Future<void> _saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(_products.map((p) => p.toJson()).toList());
      await prefs.setString('products', jsonData);
    } catch (e) {
      debugPrint('Error saving products: $e');
    }
  }

  /// Filter products by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Search products by name
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Apply all filters (category + search)
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
    notifyListeners();
  }

  // ========== Admin Operations ==========

  /// Add a new product (Admin)
  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _saveProducts();
    _applyFilters();
  }

  /// Update an existing product (Admin)
  Future<void> updateProduct(String productId, Product updatedProduct) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = updatedProduct;
      await _saveProducts();
      _applyFilters();
    }
  }

  /// Delete a product (Admin)
  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    await _saveProducts();
    _applyFilters();
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

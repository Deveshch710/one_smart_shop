import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class InventoryProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Product> _products = [];
  bool _isLoading = false;
  List<String> _categories = [];

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  List<String> get categories => _categories;

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _products.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _products = await _dbHelper.getAllProducts();
      _updateCategories();
    } catch (e) {
      print('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      final id = await _dbHelper.insertProduct(product);
      await loadProducts(); // Force reload from database
      final newProduct = product.copyWith(id: id);
      _products.add(newProduct);
      _updateCategories();
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _dbHelper.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _updateCategories();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dbHelper.deleteProduct(id);
      // Remove from local list if soft delete was successful
      _products.removeWhere((p) => p.id == id);
      _updateCategories();
      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  List<Product> searchProducts(String query) {
    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.sku.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Product> get expiringProducts {
    final now = DateTime.now();
    return _products.where((product) {
      final daysUntilExpiry = product.expiryDate.difference(now).inDays;
      return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
    }).toList();
  }

  List<Product> get expiredProducts {
    final now = DateTime.now();
    return _products.where((product) {
      return product.expiryDate.isBefore(now);
    }).toList();
  }

  void _updateCategories() {
    final categorySet = <String>{};
    for (var product in _products) {
      if (product.category.isNotEmpty) {
        categorySet.add(product.category);
      }
    }
    _categories = categorySet.toList()..sort();
    notifyListeners();
  }

  Future<List<Product>> getAllProducts() async {
    return await _dbHelper.getAllProducts();
  }

  Future<void> resetAndRestoreProducts(List<Product> products) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Reset the database
      await _dbHelper.resetDB();

      // Insert all products
      for (var product in products) {
        await _dbHelper.insertProduct(product);
      }

      // Reload products
      await loadProducts(forceRefresh: true);
    } catch (e) {
      print('Error resetting and restoring products: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

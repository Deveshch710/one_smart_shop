import 'package:flutter/foundation.dart';
import 'package:one_smart_shop/models/return.dart';
import '../database/database_helper.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/product.dart';

class SalesProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final List<Sale> _sales = [];
  final List<SaleItem> _currentCart = [];
  double _totalAmount = 0;
  double _discount = 0;

  List<Sale> get sales => _sales;
  List<SaleItem> get currentCart => _currentCart;
  double get totalAmount => _totalAmount;
  double get discount => _discount;
  double get grandTotal => _totalAmount - _discount;

  Future<void> loadSales() async {
    try {
      _sales.clear();
      _sales.addAll(await _dbHelper.getAllSales());
      notifyListeners();
    } catch (e) {
      print('Error loading sales: $e');
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    if (quantity <= 0) throw Exception('Quantity must be greater than zero');

    final dbProduct = await _dbHelper.getAllProducts();
    final stock = dbProduct.firstWhere((p) => p.id == product.id).quantity;

    if (stock < quantity) {
      throw Exception('Not enough stock available');
    }

    final existingItemIndex =
        _currentCart.indexWhere((item) => item.productId == product.id);

    if (existingItemIndex != -1) {
      final existingItem = _currentCart[existingItemIndex];
      final updatedQuantity = existingItem.quantity + quantity;

      if (updatedQuantity > stock) {
        throw Exception('Exceeds available stock');
      }

      _currentCart[existingItemIndex] = existingItem.copyWith(
        quantity: updatedQuantity,
      );
    } else {
      _currentCart.add(SaleItem(
        saleId: 0,
        productId: product.id!,
        quantity: quantity,
        unitPrice: product.sellingPrice,
      ));
    }

    _calculateTotals();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _currentCart.removeWhere((item) => item.productId == productId);
    _calculateTotals();
    notifyListeners();
  }

  void updateDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  void _calculateTotals() {
    _totalAmount = _currentCart.fold(
        0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }

  Future<String> createSale({
    String? customerName,
    String? paymentMethod,
  }) async {
    if (_currentCart.isEmpty) throw Exception('Cart is empty');

    try {
      final sale = Sale(
        invoiceNumber: _generateInvoiceNumber(),
        date: DateTime.now(),
        totalAmount: grandTotal,
        discount: _discount,
        customerName: customerName,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        items: List.from(_currentCart),
      );

      final saleId = await _dbHelper.insertSale(sale);

      for (final item in _currentCart) {
        await _dbHelper.updateProductQuantity(item.productId, -item.quantity);
      }

      final saleWithId = sale.copyWith(id: saleId);
      _sales.add(saleWithId);

      _clearCart();
      return sale.invoiceNumber;
    } catch (e) {
      print('Error creating sale: $e');
      throw Exception('Failed to create sale');
    }
  }

  void processReturn(int saleId, int productId, int quantity) async {
    double refundAmount = await DatabaseHelper.instance
        .calculateRefundAmount(productId, quantity);

    Return returnItem = Return(
      saleId: saleId,
      productId: productId,
      quantity: quantity,
      refundAmount: refundAmount,
      actualRefundReceived: refundAmount * 0.9, // Example: Supplier refunds 90%
      returnDate: DateTime.now().toIso8601String(),
      reason: "Customer Return",
    );

    await DatabaseHelper.instance.insertReturn(returnItem);

    notifyListeners(); // To update UI
  }

  void _clearCart() {
    _currentCart.clear();
    _totalAmount = 0;
    _discount = 0;
    notifyListeners();
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour}${now.minute}${now.second}';
  }
}

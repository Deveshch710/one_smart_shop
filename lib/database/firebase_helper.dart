import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one_smart_shop/models/product.dart';
import 'package:one_smart_shop/models/sale.dart';
import 'package:one_smart_shop/models/return.dart';

class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Products
  static Future<void> syncProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id.toString()).set({
        ...product.toMap(),
        'purchaseDate': product.purchaseDate,
        'expiryDate': product.expiryDate,
      }, SetOptions(merge: true));
      print("Synced product: ${product.id}");
    } catch (e) {
      print("Failed to sync product ${product.id}: $e");
    }
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> addProductWithCustomId(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id.toString())
        .set(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id.toString()).set({
      ...product.toMap(),
    }, SetOptions(merge: true));
  }

  // Sales
  static Future<void> syncSale(Sale sale) async {
    await _firestore.collection('sales').doc(sale.id.toString()).set({
      ...sale.toMap(),
      'date': sale.date,
      'createdAt': sale.createdAt,
    }, SetOptions(merge: true));
  }

  // Returns
  static Future<void> syncReturn(Return returnItem) async {
    await _firestore.collection('returns').doc(returnItem.id.toString()).set(
          returnItem.toMap(),
          SetOptions(merge: true),
        );
  }

  static Future<void> deleteFromFirestore(String collection, int id) async {
    await _firestore.collection(collection).doc(id.toString()).delete();
  }
}

class SyncManager {
  static Future<void> syncWithRetry(Function function) async {
    try {
      await function();
    } catch (e) {
      // Implement retry logic or error logging
      print('Sync error: $e');
    }
  }
}

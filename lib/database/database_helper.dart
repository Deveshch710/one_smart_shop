import 'dart:io';
import 'package:one_smart_shop/database/firebase_helper.dart';
import 'package:one_smart_shop/models/return.dart';
import 'package:one_smart_shop/models/sale.dart';
import 'package:one_smart_shop/models/sale_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/product.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<String> _getDatabasePath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await getDatabasesPath();
    }
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    return path.join(appDocDir.path, 'databases');
    // final dbDir = path.join(appDocDir.path, 'databases');
    // await Directory(dbDir).create(recursive: true);
    // return dbDir;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    print("Database Initialized"); // Log to check
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    print("Creating tables...");
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        manufacturer TEXT,
        category TEXT,
        purchasePrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        mrp REAL NOT NULL,
        quantity INTEGER NOT NULL,
        unit TEXT,
        purchaseDate TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        batchNumber TEXT,
        supplierInfo TEXT
      )
    ''');
    print("Product Table Created...");
    print("Creating tables...");
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        discount REAL NOT NULL,
        customerName TEXT,
        paymentMethod TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    print("Sales Table Created...");
    print("Creating tables...");
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        FOREIGN KEY (saleId) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE

      )
    ''');
    print("Sales_item Table Created...");

    print("Creating return Table");
    await db.execute('''
    CREATE TABLE IF NOT EXISTS returns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    saleId INTEGER NOT NULL,
    productId INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    refundAmount REAL NOT NULL,
    actualRefundReceived REAL NOT NULL,
    returnDate TEXT NOT NULL,
    reason TEXT,
    FOREIGN KEY (saleId) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE
  )
''');
    print("Returns Table Created...");
  }

  Future<Database> _initDB() async {
    final dbPath = await _getDatabasePath();
    final fullPath = path.join(dbPath, 'inventory.db');
    print("Database Path: $fullPath"); // Log the path

    return await openDatabase(
      fullPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    final productMap = product.toMap();
    productMap.remove('firestoreId'); // Remove firestoreId if not needed
    final id = await db.insert('products', productMap);
    final newProduct = product.copyWith(id: id);
    await FirebaseHelper.syncProduct(newProduct);

    return id;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? OR sku LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    await FirebaseHelper.syncProduct(product);
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    await FirebaseHelper.deleteFromFirestore('products', id);
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> hasSufficientStock(int productId, int quantity) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );

    if (result.isNotEmpty) {
      final product = Product.fromMap(result.first);
      return product.quantity >= quantity;
    }
    return false;
  }

  Future<List<Product>> getExpiringProducts(int daysThreshold) async {
    final db = await database;
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'expiryDate <= ? AND expiryDate > ?',
      whereArgs: [threshold.toIso8601String(), now.toIso8601String()],
    );
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Product>> getExpiredProducts() async {
    final db = await database;
    final now = DateTime.now();

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'expiryDate <= ?',
      whereArgs: [now.toIso8601String()],
    );
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      distinct: true,
      columns: ['category'],
    );
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<void> migrateOldData() async {
    final oldPath = path.join(Directory.current.path, '.dart_tool',
        'sqflite_common_ffi', 'databases', 'inventory.db');

    final newPath = path.join(await _getDatabasePath(), 'inventory.db');

    if (await File(oldPath).exists()) {
      await File(oldPath).copy(newPath);
      print('Migrated database from: $oldPath to $newPath');
      await File(oldPath).delete();
    }
  }

  Future<int> insertSale(Sale sale) async {
    final db = await database;
    final saleId = await db.insert('sales', sale.toMap());

    for (final item in sale.items) {
      // Insert sale item
      await db.insert('sale_items', item.toMap()..['saleId'] = saleId);
      int count = 0;
      count++;

      // Update product quantity after sale
      await updateProductQuantity(item.productId, -item.quantity + count);
    }

    return saleId;
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final sales = await db.query('sales');
    return await Future.wait(sales.map((saleMap) async {
      final sale = Sale.fromMap(saleMap);
      final items = await db.query(
        'sale_items',
        where: 'saleId = ?',
        whereArgs: [sale.id],
      );
      sale.items.addAll(items.map((itemMap) => SaleItem.fromMap(itemMap)));
      return sale;
    }));
  }

  Future<void> updateProductQuantity(int productId, int quantityChange,
      {bool isReturn = false}) async {
    final db = await database;
    await db.execute('''
    UPDATE products 
    SET quantity = quantity + ? 
    WHERE id = ? 
  ''', [quantityChange, productId]);
  }

  Future<int> insertReturn(Return returnItem) async {
    final db = await database;

    // Insert return record
    int returnId = await db.insert('returns', returnItem.toMap());

    // Update inventory
    await updateProductQuantity(returnItem.productId, returnItem.quantity,
        isReturn: true);

    return returnId;
  }

  Future<List<Return>> getAllReturns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('returns');

    return maps.map((map) => Return.fromMap(map)).toList();
  }

  Future<double> calculateRefundAmount(int productId, int quantity) async {
    final db = await database;
    final product = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );

    if (product.isNotEmpty) {
      final double sellingPrice =
          (product.first['sellingPrice'] as num).toDouble();
      return sellingPrice * quantity;
    }

    return 0.0;
  }

  Future<void> resetDB() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS sales");
    await db.execute("DROP TABLE IF EXISTS sale_items");
    await db.execute("DROP TABLE IF EXISTS products");
    await _createDB(db, 1);
    print("Database reset successful");
  }

  Future<void> syncAllData() async {
    // Sync products
    final products = await getAllProducts();
    for (final product in products) {
      await FirebaseHelper.syncProduct(product);
    }

    // Sync sales
    final sales = await getAllSales();
    for (final sale in sales) {
      await FirebaseHelper.syncSale(sale);
    }

    // Sync returns
    final returns = await getAllReturns();
    for (final returnItem in returns) {
      await FirebaseHelper.syncReturn(returnItem);
    }
  }
}

class Product {
  final int? id;
  final String sku;
  final String name;
  final String description;
  final String manufacturer;
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final double mrp;
  final int quantity;
  final String unit; // e.g., 'pieces', 'kg', 'liters'
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double? discount;
  final String? batchNumber;
  final String? supplierInfo;
  final DateTime lastUpdated;
  final bool isActive;
  String? firestoreId;

  Product({
    this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.manufacturer,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.mrp,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    required this.expiryDate,
    this.discount,
    this.batchNumber,
    this.supplierInfo,
    DateTime? lastUpdated,
    this.isActive = true,
    firestoreId,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Create a copy of the product with some fields updated
  Product copyWith({
    int? id,
    String? sku,
    String? name,
    String? description,
    String? manufacturer,
    String? category,
    double? purchasePrice,
    double? sellingPrice,
    double? mrp,
    int? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? discount,
    String? batchNumber,
    String? supplierInfo,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      mrp: mrp ?? this.mrp,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      discount: discount ?? this.discount,
      batchNumber: batchNumber ?? this.batchNumber,
      supplierInfo: supplierInfo ?? this.supplierInfo,
      lastUpdated: lastUpdated ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  // Convert to Map for database operations
  // In product.dart
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'manufacturer': manufacturer,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'mrp': mrp,
      'quantity': quantity,
      'unit': unit,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'batchNumber': batchNumber,
      'supplierInfo': supplierInfo,
      'firestoreId': firestoreId,
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      sku: map['sku'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      manufacturer: map['manufacturer'] as String,
      category: map['category'] as String,
      purchasePrice: map['purchasePrice'] as double,
      sellingPrice: map['sellingPrice'] as double,
      mrp: map['mrp'] as double,
      quantity: map['quantity'] as int,
      unit: map['unit'] as String,
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      batchNumber: map['batchNumber'] as String?,
      supplierInfo: map['supplierInfo'] as String?,
      firestoreId: map['firestoreId'],
    );
  }

  // Check if product is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  // Check if product is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }

  // Calculate current stock value
  double get stockValue => quantity * purchasePrice;

  // Calculate potential profit
  double get potentialProfit => quantity * (sellingPrice - purchasePrice);
}

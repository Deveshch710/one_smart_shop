class SaleItem {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double unitPrice;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? quantity,
    double? unitPrice,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  static SaleItem fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
    );
  }
}

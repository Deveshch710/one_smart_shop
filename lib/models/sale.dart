// models/sale.dart
import 'package:one_smart_shop/models/sale_item.dart';

class Sale {
  final int? id;
  final String invoiceNumber;
  final DateTime date;
  final double totalAmount;
  final double discount;
  final String? customerName;
  final String? paymentMethod;
  final DateTime createdAt;
  final List<SaleItem> items;

  Sale({
    this.id,
    required this.invoiceNumber,
    required this.date,
    required this.totalAmount,
    required this.discount,
    this.customerName,
    this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  Sale copyWith({
    int? id,
    String? invoiceNumber,
    DateTime? date,
    double? totalAmount,
    double? discount,
    String? customerName,
    String? paymentMethod,
    DateTime? createdAt,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? List.from(this.items), // Copy the list
    );
  }

  // fromMap constructor
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      date: DateTime.parse(map['date']),
      totalAmount: map['totalAmount'],
      discount: map['discount'],
      customerName: map['customerName'],
      paymentMethod: map['paymentMethod'],
      createdAt: DateTime.parse(map['createdAt']),
      items: [], // Initially, the items list is empty; we'll populate it later
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'discount': discount,
      'customerName': customerName,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

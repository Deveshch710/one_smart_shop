class Return {
  int? id;
  int saleId;
  int productId;
  int quantity;
  double refundAmount;
  double actualRefundReceived;
  String returnDate;
  String reason;

  Return({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.refundAmount,
    required this.actualRefundReceived,
    required this.returnDate,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'quantity': quantity,
      'refundAmount': refundAmount,
      'actualRefundReceived': actualRefundReceived,
      'returnDate': returnDate,
      'reason': reason,
    };
  }

  factory Return.fromMap(Map<String, dynamic> map) {
    return Return(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      quantity: map['quantity'],
      refundAmount: map['refundAmount'],
      actualRefundReceived: map['actualRefundReceived'],
      returnDate: map['returnDate'],
      reason: map['reason'],
    );
  }
}

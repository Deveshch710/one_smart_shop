class ReturnItem {
  final int saleId;
  final int productId;
  final int quantity;
  final double refundAmount;
  final double actualRefundReceived;
  final String returnDate;
  final String reason;

  ReturnItem({
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
      'saleId': saleId,
      'productId': productId,
      'quantity': quantity,
      'refundAmount': refundAmount,
      'actualRefundReceived': actualRefundReceived,
      'returnDate': returnDate,
      'reason': reason,
    };
  }
}

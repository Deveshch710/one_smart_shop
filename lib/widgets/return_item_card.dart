// return_item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:one_smart_shop/models/return.dart';

class ReturnItemCard extends StatelessWidget {
  final Return returnItem;

  const ReturnItemCard(this.returnItem);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Return ID: ${returnItem.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Sale ID: ${returnItem.saleId}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Product ID: ${returnItem.productId}'),
            Text('Quantity: ${returnItem.quantity}'),
            Text(
                'Refund Amount: ₹${returnItem.refundAmount.toStringAsFixed(2)}'),
            Text(
                'Date: ${DateTime.parse(returnItem.returnDate).toString().split('.')[0]}'),
            SizedBox(height: 8),
            Text(
              'Reason: ${returnItem.reason}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

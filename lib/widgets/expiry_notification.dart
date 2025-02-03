// widgets/expiry_notification.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';

class ExpiryNotification extends StatelessWidget {
  const ExpiryNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final expiring = provider.expiringProducts;
    final expired = provider.expiredProducts;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Expiry Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (expired.isNotEmpty) ...[
              const Text('Expired Products:',
                  style: TextStyle(color: Colors.red)),
              ...expired.map((p) => ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                        'Expired on ${DateFormat('dd/MM/yyyy').format(p.expiryDate)}'),
                    trailing: Text(
                        'Quantity: ${p.quantity} , Units: ${p.unit}, SKU: ${p.sku}'),
                  )),
            ],
            if (expiring.isNotEmpty) ...[
              const Text('Expiring Soon (within 30 days):',
                  style: TextStyle(color: Colors.orange)),
              ...expiring.map((p) => ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                        'Expires on ${DateFormat('dd/MM/yyyy').format(p.expiryDate)}'),
                    trailing: Text(
                        'Quantity: ${p.quantity} , Units: ${p.unit}, SKU: ${p.sku}'),
                  )),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

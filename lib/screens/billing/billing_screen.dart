// screens/billing/billing_screen.dart
import 'package:flutter/material.dart';
import 'package:one_smart_shop/screens/billing/sales_history_screen.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/product_search.dart';
import 'invoice_preview.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();
    final inventoryProvider = context.read<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
            ),
            icon: const Icon(Icons.history),
          )
        ],
      ),
      body: Column(
        children: [
          ProductSearchDelegate(
            onProductSelected: (product) => _addToCart(product, context),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: salesProvider.currentCart.length,
              itemBuilder: (context, index) {
                final item = salesProvider.currentCart[index];
                final product = inventoryProvider.products.firstWhere(
                  (p) => p.id == item.productId,
                );

                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('${item.quantity} x ₹${item.unitPrice}'),
                  trailing: Text(
                      '₹${(item.quantity * item.unitPrice).toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          _buildTotalSection(salesProvider),
          _buildActionButtons(salesProvider, context),
        ],
      ),
    );
  }

  Widget _buildTotalSection(SalesProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('₹${provider.totalAmount.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount:'),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter discount',
                    prefixText: '₹',
                  ),
                  onChanged: (value) {
                    provider.updateDiscount(double.tryParse(value) ?? 0);
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₹${provider.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SalesProvider provider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.receipt),
              label: const Text('Create Invoice'),
              onPressed: () => _completeSale(provider, context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(Product product, BuildContext context) async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (context) => QuantityDialog(product: product),
    );

    if (quantity != null && quantity > 0) {
      try {
        await context.read<SalesProvider>().addToCart(product, quantity);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _completeSale(
      SalesProvider provider, BuildContext context) async {
    final invoiceNumber = await provider.createSale(
      customerName: _customerController.text,
      paymentMethod: 'Cash', // Can implement payment method selection
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePreviewScreen(invoiceNumber: invoiceNumber),
      ),
    );
  }
}

class QuantityDialog extends StatelessWidget {
  final Product product;

  const QuantityDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: '1');
    return AlertDialog(
      title: Text('Enter Quantity for ${product.name}'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Quantity',
          suffixText: 'units',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, int.tryParse(controller.text)),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// screens/billing/sales_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one_smart_shop/models/sale_item.dart';
import 'package:one_smart_shop/screens/billing/history_bill_print.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';
import '../../models/sale.dart';
import '../../models/product.dart';
import '../../database/database_helper.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  Map<int, Product> _productsMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load all products to get their names
    final products = await DatabaseHelper.instance.getAllProducts();
    _productsMap = {for (var p in products) p.id!: p};

    await Provider.of<SalesProvider>(context, listen: false).loadSales();

    setState(() => _isLoading = false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  List<Sale> _getFilteredSales(List<Sale> allSales) {
    return allSales.where((sale) {
      return sale.date.year == _selectedDate.year &&
          sale.date.month == _selectedDate.month &&
          sale.date.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDateSelector(),
                _buildSalesSummary(),
                Expanded(child: _buildSalesList()),
              ],
            ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sales for ${DateFormat('dd MMM, yyyy').format(_selectedDate)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
            label: const Text('Change Date'),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummary() {
    return Consumer<SalesProvider>(
      builder: (context, provider, _) {
        final filteredSales = _getFilteredSales(provider.sales);
        final totalSales = filteredSales.fold(
          0.0,
          (sum, sale) => sum + sale.totalAmount,
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Sales',
                  currencyFormat.format(totalSales),
                  Icons.monetization_on_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Transactions',
                  filteredSales.length.toString(),
                  Icons.receipt_long_outlined,
                  Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return Consumer<SalesProvider>(
      builder: (context, provider, _) {
        final filteredSales = _getFilteredSales(provider.sales);

        if (filteredSales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No sales found for this date',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredSales.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) => _buildSaleCard(filteredSales[index]),
        );
      },
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        title: Text(
          'Bill #${sale.invoiceNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('hh:mm a').format(sale.date),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (sale.customerName != null)
              Text(
                'Customer: ${sale.customerName}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(sale.totalAmount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSaleInfoRow('Items', '${sale.items.length} items'),
                _buildSaleInfoRow(
                  'Subtotal',
                  currencyFormat.format(sale.totalAmount + sale.discount),
                ),
                if (sale.discount > 0)
                  _buildSaleInfoRow(
                    'Discount',
                    '- ${currencyFormat.format(sale.discount)}',
                  ),
                if (sale.paymentMethod != null)
                  _buildSaleInfoRow('Payment Method', sale.paymentMethod!),
                const Divider(),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...sale.items.map((item) => _buildItemRow(item)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      currencyFormat.format(sale.totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => printBill(context, sale),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Bill'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showReturnDialog(sale),
                      icon: const Icon(Icons.replay),
                      label: const Text('Return'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(SaleItem item) {
    final product = _productsMap[item.productId];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(product?.name ?? 'Unknown Product'),
          ),
          Expanded(
            child: Text(
              '${item.quantity} ${product?.unit ?? 'units'}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              currencyFormat.format(item.unitPrice * item.quantity),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void printBill(BuildContext context, Sale sale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceScreen(sale: sale),
      ),
    );
  }

  void _showReturnDialog(Sale sale) {
    // Show return dialog and process return
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Return'),
        content: const Text('Are you sure you want to process a return?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<SalesProvider>(context, listen: false)
                  .processReturn(sale.id!, sale.items[0].productId, 1);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Return processed successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

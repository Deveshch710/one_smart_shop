import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_smart_shop/widgets/expiry_notification.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/inventory_provider.dart';
import '../../models/product.dart';
import 'add_product.dart';

class InventoryList extends StatefulWidget {
  const InventoryList({super.key});

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showExpiryNotifications(context);
      Provider.of<InventoryProvider>(context, listen: false).loadProducts();
    });
    _loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => syncData(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showExpiryNotifications(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredProducts = _filterProducts(provider);

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('No products found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) =>
                      _buildProductCard(context, filteredProducts[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or SKU',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == 'All',
                    onSelected: (selected) {
                      setState(() => _selectedCategory = 'All');
                    },
                  ),
                  const SizedBox(width: 8),
                  ...provider.categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //Expiring products section looks After the search section
            ExpansionTile(
              title: const Text('Expiry Management'),
              initiallyExpanded: true,
              children: [
                _buildExpirySection(context, 'Expired Products',
                    provider.expiredProducts, Colors.red),
                _buildExpirySection(context, 'Expiring Soon (within 30 days)',
                    provider.expiringProducts, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building the expiry management section on inventory section
  Widget _buildExpirySection(
      BuildContext context, String title, List<Product> products, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  title.contains('Expired')
                      ? Icons.error_outline
                      : Icons.access_time,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${products.length} items',
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No items found',
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Expiry: ${DateFormat('dd/MM/yyyy').format(p.expiryDate)}',
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${p.quantity} ${p.unit}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _loadInventory() async {
    await Provider.of<InventoryProvider>(context, listen: false)
        .loadProducts(forceRefresh: true); // Force refresh every time
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final expiryDays = product.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = product.isExpiringSoon;
    final isExpired = product.isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          product.name,
          style: TextStyle(
            color: isExpired
                ? Colors.red
                : isExpiringSoon
                    ? Colors.orange
                    : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('SKU: ${product.sku}'),
        leading: _buildStockIndicator(product),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Category', product.category),
                _buildInfoRow('Manufacturer', product.manufacturer),
                _buildInfoRow('Stock', '${product.quantity} ${product.unit}'),
                _buildInfoRow('Purchase Price', '₹${product.purchasePrice}'),
                _buildInfoRow('Selling Price', '₹${product.sellingPrice}'),
                _buildInfoRow('MRP', '₹${product.mrp}'),
                _buildInfoRow(
                  'Expiry',
                  '${DateFormat('dd/MM/yyyy').format(product.expiryDate)} ${isExpired ? '(Expired)' : isExpiringSoon ? '(Expiring in $expiryDays days)' : ''}',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddProductScreen(product: product),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () => _confirmDelete(context, product),
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

  Widget _buildStockIndicator(Product product) {
    Color color;
    if (product.quantity <= 0) {
      color = Colors.red;
    } else if (product.quantity < 10) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          product.quantity.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<Product> _filterProducts(InventoryProvider provider) {
    var filteredProducts = provider.products;

    // Apply category filter
    if (_selectedCategory != 'All') {
      filteredProducts = filteredProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredProducts = provider.searchProducts(_searchQuery);
    }

    return filteredProducts;
  }

  void _showExpiryNotifications(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final expiringProducts = provider.expiringProducts;
    final expiredProducts = provider.expiredProducts;

    if (expiringProducts.isNotEmpty || expiredProducts.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ExpiryNotification(),
        //this is the code for the alert dialog
        // builder: (context) => AlertDialog(
        //   title: const Text('Product Notifications'),
        //   content: SingleChildScrollView(
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         if (expiredProducts.isNotEmpty) ...[
        //           const Text(
        //             'Expired Products:',
        //             style:
        //                 TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        //           ),
        //           const SizedBox(height: 8),
        //           ...expiredProducts.map((p) => Text('${p.name} (${p.sku})')),
        //           const SizedBox(height: 16),
        //         ],
        //         if (expiringProducts.isNotEmpty) ...[
        //           const Text(
        //             'Expiring Soon:',
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               color: Colors.orange,
        //             ),
        //           ),
        //           const SizedBox(height: 8),
        //           ...expiringProducts.map(
        //             (p) => Text(
        //               '${p.name} (${p.sku}) - Expires on ${DateFormat('dd/MM/yyyy').format(p.expiryDate)}',
        //             ),
        //           ),
        //         ],
        //         if (expiredProducts.isEmpty && expiringProducts.isEmpty)
        //           const Text('No products are expired or expiring soon.'),
        //       ],
        //     ),
        //   ),
        //   actions: [
        //     TextButton(
        //       onPressed: () => Navigator.pop(context),
        //       child: const Text('Close'),
        //     ),
        //   ],
        // ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await Provider.of<InventoryProvider>(context, listen: false)
            .deleteProduct(product.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $e')),
          );
        }
      }
    }
  }

// Function to sync data between local SQLite and cloud Firestore/PostgreSQL
  Future<void> syncData() async {
    try {
      // Step 1: Fetch unsynced data from the local SQLite database
      List<Product> unsyncedProducts = await _fetchUnsyncedProducts();

      // Step 2: If there are unsynced products, start syncing
      if (unsyncedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No unsynced products found')),
        );
        return;
      }

      for (var product in unsyncedProducts) {
        // Step 3: Sync each product with the cloud (Firestore)
        await _syncProductWithCloud(product);
      }

      // Step 4: After syncing, mark the data as synced in the local database
      await _markAsSynced(unsyncedProducts);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data synced successfully')),
      );
    } catch (error) {
      // Handle any error during the syncing process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing data: $error')),
      );
    }
  }

  // Helper methods for fetching unsynced products, syncing with cloud, etc.
  Future<List<Product>> _fetchUnsyncedProducts() async {
    // Fetch the products that are marked as unsynced
    // This could be done via a query on your SQLite database
    return [];
  }

  Future<void> _syncProductWithCloud(Product product) async {
    // Sync product with Firebase Firestore or PostgreSQL here
    // Example for Firestore:
    await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id.toString()) // Assuming `product.id` exists
        .set(product
            .toMap()); // Ensure to have a method that converts `Product` to a map
  }

  Future<void> _markAsSynced(List<Product> products) async {
    // Update the local database to mark the products as synced
    // Update the `syncStatus` or similar column in SQLite
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

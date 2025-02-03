// widgets/product_search.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';

class ProductSearchDelegate extends StatelessWidget {
  final ValueChanged<Product> onProductSelected;

  const ProductSearchDelegate({super.key, required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Autocomplete<Product>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return context
              .read<InventoryProvider>()
              .searchProducts(textEditingValue.text);
        },
        displayStringForOption: (Product option) => option.name,
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController controller,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          );
        },
        onSelected: (Product selection) {
          onProductSelected(selection);
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<Product> onSelected,
          Iterable<Product> options,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Product option = options.elementAt(index);
                    return ListTile(
                      title: Text(option.name),
                      subtitle:
                          Text('Stock: ${option.quantity} ${option.unit}'),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

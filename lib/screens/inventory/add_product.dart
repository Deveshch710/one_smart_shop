import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../providers/inventory_provider.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product; // Optional - for editing existing products

  const AddProductScreen(
      {super.key,
      this.product}); // Passing key directly to the super constructor

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  final TextEditingController _supplierInfoController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Populate fields if editing existing product
      _skuController.text = widget.product!.sku;
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _manufacturerController.text = widget.product!.manufacturer;
      _categoryController.text = widget.product!.category;
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _mrpController.text = widget.product!.mrp.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _unitController.text = widget.product!.unit;
      _batchNumberController.text = widget.product!.batchNumber ?? '';
      _supplierInfoController.text = widget.product!.supplierInfo ?? '';
      _purchaseDate = widget.product!.purchaseDate;
      _expiryDate = widget.product!.expiryDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: 'Manufacturer'),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),

              // Add Selling Price field
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Price',
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price',
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _mrpController,
                      decoration: const InputDecoration(
                        labelText: 'MRP',
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _unitController,
                decoration:
                    const InputDecoration(labelText: 'Unit (e.g., kg, pcs)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),

              // Keep existing date pickers and add new fields
              TextFormField(
                controller: _batchNumberController,
                decoration: const InputDecoration(labelText: 'Batch Number'),
              ),
              TextFormField(
                controller: _supplierInfoController,
                decoration: const InputDecoration(labelText: 'Supplier Info'),
              ),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Purchase Date'),
                      subtitle:
                          Text(DateFormat('dd/MM/yyyy').format(_purchaseDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _purchaseDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _purchaseDate = date);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Expiry Date'),
                      subtitle:
                          Text(DateFormat('dd/MM/yyyy').format(_expiryDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _expiryDate = date);
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  child: Text(widget.product == null
                      ? 'Add Product'
                      : 'Update Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        sku: _skuController.text,
        name: _nameController.text,
        description: _descriptionController.text,
        manufacturer: _manufacturerController.text,
        category: _categoryController.text,
        purchasePrice: double.parse(_purchasePriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        mrp: double.parse(_mrpController.text),
        purchaseDate: _purchaseDate,
        expiryDate: _expiryDate,
        batchNumber: _batchNumberController.text,
        supplierInfo: _supplierInfoController.text,
      );

      try {
        final provider = Provider.of<InventoryProvider>(context, listen: false);
        if (widget.product == null) {
          await provider.addProduct(product);
        } else {
          await provider.updateProduct(product);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}

// return_form.dart
import 'package:flutter/material.dart';
import 'package:one_smart_shop/database/database_helper.dart';
import 'package:one_smart_shop/models/return.dart';
import 'package:one_smart_shop/providers/returns_provider.dart';
import 'package:provider/provider.dart';

class ReturnForm extends StatefulWidget {
  @override
  _ReturnFormState createState() => _ReturnFormState();
}

class _ReturnFormState extends State<ReturnForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _saleIdController = TextEditingController();
  final _productIdController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  double _calculatedRefund = 0.0;

  @override
  void dispose() {
    _saleIdController.dispose();
    _productIdController.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _calculateRefund() async {
    if (_productIdController.text.isEmpty || _quantityController.text.isEmpty) {
      return;
    }

    try {
      final refund = await DatabaseHelper.instance.calculateRefundAmount(
        int.parse(_productIdController.text),
        int.parse(_quantityController.text),
      );
      setState(() => _calculatedRefund = refund);
    } catch (e) {
      print('Error calculating refund: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final returnItem = Return(
        saleId: int.parse(_saleIdController.text),
        productId: int.parse(_productIdController.text),
        quantity: int.parse(_quantityController.text),
        refundAmount: _calculatedRefund,
        actualRefundReceived: _calculatedRefund,
        returnDate: DateTime.now().toIso8601String(),
        reason: _reasonController.text,
      );

      final returnsProvider =
          Provider.of<ReturnsProvider>(context, listen: false);
      await returnsProvider.addReturn(returnItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Return processed successfully')),
        );

        // Reset form fields
        _saleIdController.clear();
        _productIdController.clear();
        _quantityController.clear();
        _reasonController.clear();
        setState(() {
          _calculatedRefund = 0.0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing return: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Process Return'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _saleIdController,
                decoration: InputDecoration(
                  labelText: 'Sale ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Sale ID is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _productIdController,
                decoration: InputDecoration(
                  labelText: 'Product ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Product ID is required' : null,
                onChanged: (_) => _calculateRefund(),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Quantity is required';
                  final quantity = int.tryParse(value!);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
                onChanged: (_) => _calculateRefund(),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Return Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Reason is required' : null,
              ),
              SizedBox(height: 16),
              if (_calculatedRefund > 0)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Refund Amount: ₹${_calculatedRefund.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Process Return'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

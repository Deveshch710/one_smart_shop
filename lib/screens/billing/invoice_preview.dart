// screens/billing/invoice_preview.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final String invoiceNumber;

  const InvoicePreviewScreen({super.key, required this.invoiceNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printInvoice(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(context, format),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      BuildContext context, PdfPageFormat format) async {
    final sale = context.read<SalesProvider>().sales.firstWhere(
          (s) => s.invoiceNumber == invoiceNumber,
        );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0, child: pw.Text('Invoice #${sale.invoiceNumber}')),
              pw.Text('Date: ${sale.date.toString()}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Product', 'Qty', 'Price', 'Total'],
                data: sale.items.map((item) {
                  return [
                    item.productId
                        .toString(), // Replace with actual product name
                    item.quantity.toString(),
                    '₹${item.unitPrice.toStringAsFixed(2)}',
                    '₹${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grand Total:'),
                  pw.Text('₹${sale.totalAmount.toStringAsFixed(2)}'),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _printInvoice(BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (format) => _generatePdf(context, format),
    );
  }
}

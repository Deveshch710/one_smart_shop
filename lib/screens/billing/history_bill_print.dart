import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:one_smart_shop/models/sale.dart';
import 'package:one_smart_shop/models/sale_item.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share/share.dart';

class InvoiceScreen extends StatelessWidget {
  final Sale sale;

  const InvoiceScreen({Key? key, required this.sale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice: ${sale.invoiceNumber}'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              _printInvoice(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _shareInvoice(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceHeader(),
            SizedBox(height: 20),
            _buildInvoiceItems(),
            Divider(),
            _buildInvoiceSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invoice Number: ${sale.invoiceNumber}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Date: ${DateFormat('dd/MM/yyyy').format(sale.date)}',
            style: TextStyle(fontSize: 16)),
        if (sale.customerName != null)
          Text('Customer: ${sale.customerName}',
              style: TextStyle(fontSize: 16)),
        if (sale.paymentMethod != null)
          Text('Payment Method: ${sale.paymentMethod}',
              style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildInvoiceItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Table(
          border: TableBorder.all(),
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                _buildTableHeader('Product ID'),
                _buildTableHeader('Qty'),
                _buildTableHeader('Unit Price'),
                _buildTableHeader('Total'),
              ],
            ),
            ...sale.items.map((SaleItem item) {
              return TableRow(children: [
                _buildTableCell(item.productId.toString()),
                _buildTableCell(item.quantity.toString()),
                _buildTableCell('\₹${item.unitPrice.toStringAsFixed(2)}'),
                _buildTableCell(
                    '\₹${(item.quantity * item.unitPrice).toStringAsFixed(2)}'),
              ]);
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader(String title) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subtotal: \$${sale.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text('Discount: \$${sale.discount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Divider(),
        Text(
            'Total: \$${(sale.totalAmount - sale.discount).toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<Uint8List> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0, child: pw.Text('Invoice #${sale.invoiceNumber}')),
              pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(sale.date)}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Product ID', 'Qty', 'Unit Price', 'Total'],
                data: sale.items.map((item) {
                  return [
                    item.productId.toString(),
                    item.quantity.toString(),
                    '\$${item.unitPrice.toStringAsFixed(2)}',
                    '\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:'),
                  pw.Text(
                      '\$${(sale.totalAmount - sale.discount).toStringAsFixed(2)}'),
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
      onLayout: (format) => _generatePdf(context),
    );
  }

  Future<void> _shareInvoice(BuildContext context) async {
    final pdfData = await _generatePdf(context);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/invoice_${sale.invoiceNumber}.pdf');
    await file.writeAsBytes(pdfData);
    Share.shareFiles([file.path], text: 'Invoice #${sale.invoiceNumber}');
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/app_button.dart';

/// Sale summary/invoice screen
class SaleSummaryScreen extends StatelessWidget {
  final String saleId;

  const SaleSummaryScreen({super.key, required this.saleId});

  // Mock data
  Map<String, dynamic> get _mockSale => {
        'invoiceNumber': 'INV-2024-001',
        'date': DateTime.now(),
        'items': [
          {'name': 'Paracetamol 500mg', 'quantity': 2, 'price': 5.99, 'total': 11.98},
          {'name': 'Aspirin 100mg', 'quantity': 1, 'price': 3.50, 'total': 3.50},
        ],
        'subtotal': 15.48,
        'discount': 0.0,
        'tax': 1.55,
        'total': 17.03,
        'paymentMethod': 'Cash',
        'staffName': 'John Doe',
      };

  @override
  Widget build(BuildContext context) {
    final sale = _mockSale;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print, size: 20),
                    SizedBox(width: 8),
                    Text('Print Receipt'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Download PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'print') {
                await _printReceipt(context);
              } else if (value == 'download') {
                await _downloadReceipt(context);
              } else if (value == 'share') {
                await _shareReceipt(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Invoice header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'INVOICE',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sale['invoiceNumber'],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormatter.toDisplayDateTime(sale['date'] as DateTime),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Items
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Divider(),
                  ...(sale['items'] as List).map((item) {
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text('Qty: ${item['quantity']} x ${CurrencyFormatter.format(item['price'])}'),
                      trailing: Text(
                        CurrencyFormatter.format(item['total']),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Totals
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalRow(context, 'Subtotal', sale['subtotal']),
                    if (sale['discount'] > 0)
                      _buildTotalRow(context, 'Discount', -sale['discount']),
                    _buildTotalRow(context, 'Tax', sale['tax']),
                    const Divider(),
                    _buildTotalRow(
                      context,
                      'Total',
                      sale['total'],
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment info
            Card(
              child: ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Payment Method'),
                trailing: Text(sale['paymentMethod']),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Print Receipt',
                    onPressed: () => _printReceipt(context),
                    icon: Icons.print,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Download PDF',
                    onPressed: () => _downloadReceipt(context),
                    icon: Icons.download,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Share Receipt',
              onPressed: () => _shareReceipt(context),
              icon: Icons.share,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipt(BuildContext context) async {
    try {
      final pdfBytes = await _generateReceiptPdf();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt sent to printer'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final pdfBytes = await _generateReceiptPdf();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/receipt_${saleId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      await OpenFilex.open(filePath);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt downloaded: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final pdfBytes = await _generateReceiptPdf();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/receipt_${saleId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      // Share file - in production, use share_plus package
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt ready to share: $filePath'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generateReceiptPdf() async {
    final sale = _mockSale;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'PHARMACY POS',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Invoice #${sale['invoiceNumber']}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    DateFormatter.toDisplayDateTime(sale['date'] as DateTime),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),

            // Items
            ...(sale['items'] as List).map((item) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            item['name'],
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            '${item['quantity']} x ${CurrencyFormatter.format(item['price'])}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(item['total']),
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),

            pw.Divider(),
            pw.SizedBox(height: 10),

            // Totals
            _buildPdfTotalRow('Subtotal', sale['subtotal']),
            if (sale['discount'] > 0)
              _buildPdfTotalRow('Discount', -sale['discount']),
            _buildPdfTotalRow('Tax', sale['tax']),
            pw.Divider(),
            _buildPdfTotalRow('Total', sale['total'], isTotal: true),

            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'Payment: ${sale['paymentMethod']}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Thank you for your purchase!',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  pw.Widget _buildPdfTotalRow(String label, double amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            CurrencyFormatter.format(amount),
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}


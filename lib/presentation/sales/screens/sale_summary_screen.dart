import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/invoice_pdf_builder.dart';
import '../../widgets/app_button.dart';

/// Sale summary/invoice screen
class SaleSummaryScreen extends StatelessWidget {
  final String saleId;

  const SaleSummaryScreen({super.key, required this.saleId});

  // Mock data - Invoice-PWD48Y7J-0003 format
  Map<String, dynamic> get _mockSale => {
        'storeCode': 'PWD48Y7J',
        'invoiceNumber': 3,
        'invoiceId': 'PWD48Y7J-0003',
        'date': DateTime.now(),
        'businessName': 'My Pharmacy',
        'address': '123 Main Street, City',
        'phone': '+1234567890',
        'items': [
          {'name': 'Paracetamol 500mg', 'quantity': 2, 'price': 5.99, 'total': 11.98},
          {'name': 'Aspirin 100mg', 'quantity': 1, 'price': 3.50, 'total': 3.50},
        ],
        'subtotal': 15.48,
        'discount': 0.0,
        'tax': 1.55,
        'total': 17.03,
        'paymentMethod': 'Cash',
        'customerName': 'Walk-in Customer',
        'staffName': 'John Doe',
      };

  @override
  Widget build(BuildContext context) {
    final sale = _mockSale;
    
    // Back from invoice → POS screen
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && context.mounted) context.go(AppRoutes.pos);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sale Summary'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.pos),
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
                      sale['invoiceId'] ?? sale['invoiceNumber']?.toString() ?? '',
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
      final sale = _mockSale;
      final invoiceData = _buildInvoicePdfData(sale);
      final pdfBytes = await InvoicePdfBuilder.buildPdf(invoiceData);
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
      final sale = _mockSale;
      final invoiceData = _buildInvoicePdfData(sale);
      final pdfBytes = await InvoicePdfBuilder.buildPdf(invoiceData);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${invoiceData.fileName}';
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
      final sale = _mockSale;
      final invoiceData = _buildInvoicePdfData(sale);
      final pdfBytes = await InvoicePdfBuilder.buildPdf(invoiceData);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${invoiceData.fileName}';
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

  InvoicePdfData _buildInvoicePdfData(Map<String, dynamic> sale) {
    return InvoicePdfData(
      storeCode: sale['storeCode'] as String? ?? 'PWD48Y7J',
      invoiceNumber: (sale['invoiceNumber'] as int?) ?? 1,
      date: sale['date'] as DateTime,
      businessName: sale['businessName'] as String? ?? 'My Pharmacy',
      logoBytes: sale['logoBytes'] != null
          ? Uint8List.fromList((sale['logoBytes'] as List<int>))
          : null,
      address: sale['address'] as String?,
      phone: sale['phone'] as String?,
      items: (sale['items'] as List).map((item) => InvoicePdfItem(
        productName: item['name'] as String,
        quantity: item['quantity'] as int,
        unitPrice: (item['price'] as num).toDouble(),
        total: (item['total'] as num).toDouble(),
      )).toList(),
      subtotal: (sale['subtotal'] as num).toDouble(),
      discount: (sale['discount'] as num).toDouble(),
      tax: (sale['tax'] as num).toDouble(),
      total: (sale['total'] as num).toDouble(),
      paymentMethod: sale['paymentMethod'] as String,
      customerName: sale['customerName'] as String?,
      staffName: sale['staffName'] as String?,
    );
  }
}


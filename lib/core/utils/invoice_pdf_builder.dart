import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import '../../domain/entities/sale.dart' as domain;
import 'package:pdf/widgets.dart' as pw;
import 'currency_formatter.dart';
import 'date_formatter.dart';

/// Invoice line item for PDF
class InvoicePdfItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  const InvoicePdfItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

/// Data for generating invoice PDF - Invoice-PWD48Y7J-0003 format
class InvoicePdfData {
  /// Store/business code (e.g. PWD48Y7J) - used in invoice ID and filename
  final String storeCode;

  /// Sequential invoice number, zero-padded to 4 digits (e.g. 0003)
  final int invoiceNumber;

  /// Invoice date - required
  final DateTime date;

  /// Business/store name - your pharmacy name
  final String businessName;

  /// Optional logo image bytes - add your logo
  final Uint8List? logoBytes;

  /// Optional address/contact info
  final String? address;
  final String? phone;

  /// Line items
  final List<InvoicePdfItem> items;

  /// Subtotal
  final double subtotal;

  /// Discount amount
  final double discount;

  /// Tax amount
  final double tax;

  /// Total amount
  final double total;

  /// Payment method
  final String paymentMethod;

  /// Customer name (optional)
  final String? customerName;

  /// Staff name (optional)
  final String? staffName;

  const InvoicePdfData({
    required this.storeCode,
    required this.invoiceNumber,
    required this.date,
    required this.businessName,
    this.logoBytes,
    this.address,
    this.phone,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.customerName,
    this.staffName,
  });

  /// Full invoice ID in format: PWD48Y7J-0003
  String get invoiceId => '$storeCode-${invoiceNumber.toString().padLeft(4, '0')}';

  /// Filename in format: Invoice-PWD48Y7J-0003.pdf
  String get fileName => 'Invoice-$invoiceId.pdf';

  /// Create from Sale entity (when using real API data)
  factory InvoicePdfData.fromSale({
    required domain.Sale sale,
    required String storeCode,
    required String businessName,
    Uint8List? logoBytes,
    String? address,
    String? phone,
  }) {
    // Parse invoice number from format like PWD48Y7J-0003 or INV-001
    int seqNum = 1;
    final parts = sale.invoiceNumber.split('-');
    if (parts.length >= 2) {
      seqNum = int.tryParse(parts.last) ?? 1;
    }
    return InvoicePdfData(
      storeCode: storeCode,
      invoiceNumber: seqNum,
      date: sale.createdAt,
      businessName: businessName,
      logoBytes: logoBytes,
      address: address,
      phone: phone,
      items: sale.items.map((i) => InvoicePdfItem(
        productName: i.productName,
        quantity: i.quantity,
        unitPrice: i.unitPrice,
        total: i.total,
      )).toList(),
      subtotal: sale.subtotal,
      discount: sale.discount,
      tax: sale.tax,
      total: sale.total,
      paymentMethod: sale.paymentMethod.displayName,
      customerName: sale.customerName,
      staffName: null,
    );
  }
}

/// Reusable invoice PDF builder - generates Invoice-PWD48Y7J-0003 format
class InvoicePdfBuilder {
  /// Build PDF document from invoice data
  static Future<Uint8List> buildPdf(InvoicePdfData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header: Logo + Business name
              _buildHeader(data),
              pw.SizedBox(height: 24),

              // Invoice title + number + date
              _buildInvoiceInfo(data),
              pw.SizedBox(height: 20),

              // Customer (if any)
              if (data.customerName != null) ...[
                _buildCustomerInfo(data.customerName!),
                pw.SizedBox(height: 16),
              ],

              // Items table
              _buildItemsTable(data),
              pw.SizedBox(height: 20),

              // Totals
              _buildTotals(data),
              pw.SizedBox(height: 24),

              // Payment & footer
              _buildFooter(data),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(InvoicePdfData data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.logoBytes != null && data.logoBytes!.isNotEmpty)
                pw.Image(
                  pw.MemoryImage(data.logoBytes!),
                  width: 80,
                  height: 80,
                  fit: pw.BoxFit.contain,
                )
              else
                pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'LOGO',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),
                ),
              pw.SizedBox(height: 12),
              pw.Text(
                data.businessName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (data.address != null && data.address!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  data.address!,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
              if (data.phone != null && data.phone!.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  data.phone!,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(InvoicePdfData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                data.invoiceId,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Date',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                DateFormatter.toDisplayDate(data.date),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                DateFormatter.toTime(data.date),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(String customerName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Customer: ',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            customerName,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(InvoicePdfData data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _tableCell('Product', isHeader: true),
            _tableCell('Qty', isHeader: true),
            _tableCell('Price', isHeader: true),
            _tableCell('Total', isHeader: true),
          ],
        ),
        // Item rows
        ...data.items.map((item) => pw.TableRow(
              children: [
                _tableCell(item.productName),
                _tableCell('${item.quantity}'),
                _tableCell(CurrencyFormatter.format(item.unitPrice)),
                _tableCell(CurrencyFormatter.format(item.total)),
              ],
            )),
      ],
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildTotals(InvoicePdfData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _totalRow('Subtotal', data.subtotal),
          if (data.discount > 0) _totalRow('Discount', -data.discount),
          _totalRow('Tax', data.tax),
          pw.Divider(),
          _totalRow('Total', data.total, isTotal: true),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(String label, double amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            CurrencyFormatter.format(amount),
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(InvoicePdfData data) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Payment: ${data.paymentMethod}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            if (data.staffName != null)
              pw.Text(
                'Served by: ${data.staffName}',
                style: const pw.TextStyle(fontSize: 9),
              ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Text(
            'Thank you for your purchase!',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

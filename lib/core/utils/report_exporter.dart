import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Report exporter utility for Word/Excel export
class ReportExporter {
  /// Export sales report to Excel
  static Future<void> exportSalesReportToExcel({
    required List<Map<String, dynamic>> salesData,
    required String fileName,
  }) async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Sales Report'];

      // Headers
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Invoice Number');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Date');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Customer');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Items');
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Subtotal');
      sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Discount');
      sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Tax');
      sheet.cell(CellIndex.indexByString('H1')).value = TextCellValue('Total');
      sheet.cell(CellIndex.indexByString('I1')).value = TextCellValue('Payment Method');

      // Style headers
      for (int i = 0; i < 9; i++) {
        final cellIndex = CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0);
        final cell = sheet.cell(cellIndex);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'),
        );
      }

      // Data rows
      for (int i = 0; i < salesData.length; i++) {
        final sale = salesData[i];
        final rowIndex = i + 1;

        sheet.cell(CellIndex.indexByString('A${rowIndex + 1}')).value = TextCellValue(sale['invoiceNumber']?.toString() ?? '');
        if (sale['date'] != null) {
          try {
            final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(sale['date'].toString()));
            sheet.cell(CellIndex.indexByString('B${rowIndex + 1}')).value = TextCellValue(dateStr);
          } catch (e) {
            sheet.cell(CellIndex.indexByString('B${rowIndex + 1}')).value = TextCellValue(sale['date']?.toString() ?? '');
          }
        }
        sheet.cell(CellIndex.indexByString('C${rowIndex + 1}')).value = TextCellValue(sale['customer']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('D${rowIndex + 1}')).value = IntCellValue(sale['items'] ?? 0);
        sheet.cell(CellIndex.indexByString('E${rowIndex + 1}')).value = DoubleCellValue((sale['subtotal'] ?? 0.0).toDouble());
        sheet.cell(CellIndex.indexByString('F${rowIndex + 1}')).value = DoubleCellValue((sale['discount'] ?? 0.0).toDouble());
        sheet.cell(CellIndex.indexByString('G${rowIndex + 1}')).value = DoubleCellValue((sale['tax'] ?? 0.0).toDouble());
        sheet.cell(CellIndex.indexByString('H${rowIndex + 1}')).value = DoubleCellValue((sale['total'] ?? 0.0).toDouble());
        sheet.cell(CellIndex.indexByString('I${rowIndex + 1}')).value = TextCellValue(sale['paymentMethod']?.toString() ?? '');
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      // Open file
      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Failed to export Excel: $e');
    }
  }

  /// Export inventory report to Excel
  static Future<void> exportInventoryReportToExcel({
    required List<Map<String, dynamic>> inventoryData,
    required String fileName,
  }) async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Inventory Report'];

      // Headers
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Product Name');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('SKU');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Barcode');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Current Stock');
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Low Stock Threshold');
      sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Status');
      sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Expiry Date');
      sheet.cell(CellIndex.indexByString('H1')).value = TextCellValue('Batch Number');

      // Style headers
      for (int i = 0; i < 8; i++) {
        final cellIndex = CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0);
        final cell = sheet.cell(cellIndex);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'),
        );
      }

      // Data rows
      for (int i = 0; i < inventoryData.length; i++) {
        final item = inventoryData[i];
        final rowIndex = i + 1;

        sheet.cell(CellIndex.indexByString('A${rowIndex + 1}')).value = TextCellValue(item['productName']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('B${rowIndex + 1}')).value = TextCellValue(item['sku']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('C${rowIndex + 1}')).value = TextCellValue(item['barcode']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('D${rowIndex + 1}')).value = IntCellValue(item['currentStock'] ?? 0);
        sheet.cell(CellIndex.indexByString('E${rowIndex + 1}')).value = IntCellValue(item['lowStockThreshold'] ?? 0);
        sheet.cell(CellIndex.indexByString('F${rowIndex + 1}')).value = TextCellValue(item['status']?.toString() ?? '');
        if (item['expiryDate'] != null) {
          try {
            final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(item['expiryDate'].toString()));
            sheet.cell(CellIndex.indexByString('G${rowIndex + 1}')).value = TextCellValue(dateStr);
          } catch (e) {
            sheet.cell(CellIndex.indexByString('G${rowIndex + 1}')).value = TextCellValue(item['expiryDate']?.toString() ?? '');
          }
        }
        sheet.cell(CellIndex.indexByString('H${rowIndex + 1}')).value = TextCellValue(item['batchNumber']?.toString() ?? '');
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      // Open file
      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Failed to export Excel: $e');
    }
  }

  /// Export report to Word (as formatted text file)
  static Future<void> exportReportToWord({
    required String title,
    required List<Map<String, dynamic>> data,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.docx';
      final file = File(filePath);

      final buffer = StringBuffer();
      buffer.writeln(title);
      buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
      buffer.writeln('');
      buffer.writeln('=' * 50);
      buffer.writeln('');

      for (final item in data) {
        item.forEach((key, value) {
          buffer.writeln('$key: $value');
        });
        buffer.writeln('');
        buffer.writeln('-' * 50);
        buffer.writeln('');
      }

      await file.writeAsString(buffer.toString());
      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Failed to export Word: $e');
    }
  }

  /// Export sales report to PDF
  static Future<void> exportSalesReportToPdf({
    required List<Map<String, dynamic>> salesData,
    required String fileName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Sales Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Date range
              if (startDate != null || endDate != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 20),
                  child: pw.Text(
                    'Period: ${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : 'N/A'} - ${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : 'N/A'}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),

              // Summary
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Invoice', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...salesData.map((sale) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(sale['invoiceNumber']?.toString() ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            sale['date'] != null
                                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(sale['date'].toString()))
                                : '',
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(sale['customer']?.toString() ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('\$${(sale['total'] ?? 0.0).toStringAsFixed(2)}'),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 20),

              // Totals
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    color: PdfColors.grey200,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total Sales: \$${salesData.fold<double>(0, (sum, sale) => sum + ((sale['total'] ?? 0.0) as num).toDouble()).toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                      pw.Text(
                        'Total Transactions: ${salesData.length}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Save and open PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Open file
      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  /// Export inventory report to PDF
  static Future<void> exportInventoryReportToPdf({
    required List<Map<String, dynamic>> inventoryData,
    required String fileName,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Inventory Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Product', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('SKU', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Stock', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...inventoryData.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item['productName']?.toString() ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item['sku']?.toString() ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text((item['currentStock'] ?? 0).toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item['status']?.toString() ?? ''),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      // Save and open PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Open file
      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }
}

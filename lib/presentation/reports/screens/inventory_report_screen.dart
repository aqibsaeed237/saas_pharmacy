import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/report_exporter.dart';
import '../../widgets/app_button.dart';

/// Inventory report screen
class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inventory report generated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateReport,
            tooltip: 'Generate Report',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.download),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 20),
                    SizedBox(width: 8),
                    Text('Export to Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'word',
                child: Row(
                  children: [
                    Icon(Icons.description, size: 20),
                    SizedBox(width: 8),
                    Text('Export to Word'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 20),
                    SizedBox(width: 8),
                    Text('Export to PDF'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'excel') {
                await _exportToExcel(context);
              } else if (value == 'word') {
                await _exportToWord(context);
              } else if (value == 'pdf') {
                await _exportToPdf(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Generate Report Button
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Generate Report',
                onPressed: _generateReport,
                icon: Icons.assessment,
              ),
            ),
          ),

          // Low stock
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.warning_amber, color: Colors.orange),
              title: const Text('Low Stock Items'),
              subtitle: const Text('5 items'),
              children: [
                ListTile(
                  title: const Text('Paracetamol 500mg'),
                  subtitle: const Text('Stock: 5 units'),
                  trailing: const Chip(
                    label: Text('Low'),
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Expiring soon
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.calendar_today, color: Colors.red),
              title: const Text('Expiring Soon'),
              subtitle: const Text('3 items'),
              children: [
                ListTile(
                  title: const Text('Aspirin 100mg'),
                  subtitle: const Text('Expires: 15/06/2024'),
                  trailing: const Chip(
                    label: Text('30 days'),
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Out of stock
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.inventory_2, color: Colors.grey),
              title: const Text('Out of Stock'),
              subtitle: const Text('2 items'),
              children: [
                ListTile(
                  title: const Text('Ibuprofen 200mg'),
                  subtitle: const Text('Stock: 0 units'),
                  trailing: const Chip(
                    label: Text('Out'),
                    backgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      final mockInventoryData = [
        {
          'productName': 'Paracetamol 500mg',
          'sku': 'PRC-500',
          'barcode': '1234567890123',
          'currentStock': 50,
          'lowStockThreshold': 20,
          'status': 'In Stock',
          'expiryDate': DateTime.now().add(const Duration(days: 180)).toIso8601String(),
          'batchNumber': 'BATCH001',
        },
        {
          'productName': 'Aspirin 100mg',
          'sku': 'ASP-100',
          'barcode': '1234567890124',
          'currentStock': 5,
          'lowStockThreshold': 20,
          'status': 'Low Stock',
          'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'batchNumber': 'BATCH002',
        },
      ];

      await ReportExporter.exportInventoryReportToExcel(
        inventoryData: mockInventoryData,
        fileName: 'inventory_report_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report exported to Excel successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToWord(BuildContext context) async {
    try {
      final mockInventoryData = [
        {
          'Product Name': 'Paracetamol 500mg',
          'Current Stock': '50',
          'Status': 'In Stock',
        },
        {
          'Product Name': 'Aspirin 100mg',
          'Current Stock': '5',
          'Status': 'Low Stock',
        },
      ];

      await ReportExporter.exportReportToWord(
        title: 'Inventory Report',
        data: mockInventoryData,
        fileName: 'inventory_report_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report exported to Word successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToPdf(BuildContext context) async {
    try {
      final mockInventoryData = [
        {
          'productName': 'Paracetamol 500mg',
          'sku': 'PRC-500',
          'barcode': '1234567890123',
          'currentStock': 50,
          'lowStockThreshold': 20,
          'status': 'In Stock',
          'expiryDate': DateTime.now().add(const Duration(days: 180)).toIso8601String(),
          'batchNumber': 'BATCH001',
        },
        {
          'productName': 'Aspirin 100mg',
          'sku': 'ASP-100',
          'barcode': '1234567890124',
          'currentStock': 5,
          'lowStockThreshold': 20,
          'status': 'Low Stock',
          'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'batchNumber': 'BATCH002',
        },
      ];

      await ReportExporter.exportInventoryReportToPdf(
        inventoryData: mockInventoryData,
        fileName: 'inventory_report_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report exported to PDF successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

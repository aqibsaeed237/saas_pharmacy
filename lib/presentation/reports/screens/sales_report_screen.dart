import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/report_exporter.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Sales report screen
class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStaff;

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('salesReport') ?? 'Sales Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.pushNamed('reportsMetrics'),
            tooltip: loc?.translate('viewMetrics') ?? 'View Metrics',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.download),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    const Icon(Icons.table_chart, size: 20),
                    const SizedBox(width: 8),
                    Text(loc?.translate('exportToExcel') ?? 'Export to Excel'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'word',
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 20),
                    const SizedBox(width: 8),
                    Text(loc?.translate('exportToWord') ?? 'Export to Word'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'excel') {
                await _exportToExcel();
              } else if (value == 'word') {
                await _exportToWord();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc?.translate('filters') ?? 'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final loc = AppLocalizations.of(context);
                            return InkWell(
                              onTap: _selectStartDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: loc?.translate('startDate') ?? 'Start Date',
                                  prefixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : (loc?.translate('selectDate') ?? 'Select date'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final loc = AppLocalizations.of(context);
                            return InkWell(
                              onTap: _selectEndDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: loc?.translate('endDate') ?? 'End Date',
                                  prefixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : (loc?.translate('selectDate') ?? 'Select date'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: loc?.translate('generateReport') ?? 'Generate Report',
                    onPressed: _generateReport,
                    icon: Icons.assessment,
                  ),
                ],
              ),
            ),
          ),

          // Report summary
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final loc = AppLocalizations.of(context);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc?.translate('summary') ?? 'Summary',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                _buildSummaryRow(loc?.translate('totalSales') ?? 'Total Sales', CurrencyFormatter.format(12450.50)),
                                _buildSummaryRow(loc?.translate('totalTransactions') ?? 'Total Transactions', '245'),
                                _buildSummaryRow(loc?.translate('averageSale') ?? 'Average Sale', CurrencyFormatter.format(50.82)),
                                _buildSummaryRow(loc?.translate('topProduct') ?? 'Top Product', 'Paracetamol 500mg'),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateReport() {
    // Generate report with current filters
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc?.translate('reportGeneratedSuccessfully') ?? 'Report generated successfully')),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      final mockSalesData = [
        {
          'invoiceNumber': 'INV-001',
          'date': DateTime.now().toIso8601String(),
          'customer': 'John Doe',
          'items': 3,
          'subtotal': 50.0,
          'discount': 5.0,
          'tax': 4.5,
          'total': 49.5,
          'paymentMethod': 'Cash',
        },
        {
          'invoiceNumber': 'INV-002',
          'date': DateTime.now().toIso8601String(),
          'customer': 'Jane Smith',
          'items': 2,
          'subtotal': 30.0,
          'discount': 0.0,
          'tax': 2.7,
          'total': 32.7,
          'paymentMethod': 'Card',
        },
      ];

      await ReportExporter.exportSalesReportToExcel(
        salesData: mockSalesData,
        fileName: 'sales_report_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc?.translate('reportExportedToExcelSuccessfully') ?? 'Report exported to Excel successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.translate('error') ?? 'Error'}: $e')),
        );
      }
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final mockSalesData = [
        {
          'invoiceNumber': 'INV-001',
          'date': DateTime.now().toIso8601String(),
          'customer': 'John Doe',
          'items': 3,
          'subtotal': 50.0,
          'discount': 5.0,
          'tax': 4.5,
          'total': 49.5,
          'paymentMethod': 'Cash',
        },
        {
          'invoiceNumber': 'INV-002',
          'date': DateTime.now().toIso8601String(),
          'customer': 'Jane Smith',
          'items': 2,
          'subtotal': 30.0,
          'discount': 0.0,
          'tax': 2.7,
          'total': 32.7,
          'paymentMethod': 'Card',
        },
      ];

      await ReportExporter.exportSalesReportToPdf(
        salesData: mockSalesData,
        fileName: 'sales_report_${DateTime.now().millisecondsSinceEpoch}',
        startDate: _startDate,
        endDate: _endDate,
      );

      if (context.mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc?.translate('reportExportedToPdfSuccessfully') ?? 'Report exported to PDF successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc?.translate('errorExportingPdf') ?? 'Error exporting PDF'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToWord() async {
    try {
      final mockSalesData = [
        {
          'Invoice Number': 'INV-001',
          'Date': DateTime.now().toString(),
          'Customer': 'John Doe',
          'Total': '\$49.50',
        },
        {
          'Invoice Number': 'INV-002',
          'Date': DateTime.now().toString(),
          'Customer': 'Jane Smith',
          'Total': '\$32.70',
        },
      ];

      await ReportExporter.exportReportToWord(
        title: 'Sales Report',
        data: mockSalesData,
        fileName: 'sales_report_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc?.translate('reportExportedToWordSuccessfully') ?? 'Report exported to Word successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.translate('error') ?? 'Error'}: $e')),
        );
      }
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


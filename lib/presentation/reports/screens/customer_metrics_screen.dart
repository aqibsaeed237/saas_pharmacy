import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/localization/app_localizations.dart';

/// Customer Metrics screen with charts
class CustomerMetricsScreen extends StatelessWidget {
  const CustomerMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('customerMetrics') ?? 'Customer Metrics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context, loc),
            tooltip: loc?.translate('shareReport') ?? 'Share Report',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReport(context, loc),
            tooltip: loc?.translate('printReport') ?? 'Print Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc?.translate('customerMetrics') ?? 'Customer Metrics',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc?.translate('analyzeCustomerBehavior') ?? 'Analyze customer behavior and engagement patterns.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    // Mock chart
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 3),
                                const FlSpot(1, 1),
                                const FlSpot(2, 4),
                                const FlSpot(3, 2),
                              ],
                              isCurved: true,
                              color: Colors.pink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareReport(BuildContext context, AppLocalizations? loc) async {
    try {
      await Share.share('${loc?.translate('customerMetrics') ?? 'Customer Metrics'} Report\n\nGenerated from Pharmacy POS');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.translate('errorSharingReport') ?? 'Error sharing report'}: $e')),
        );
      }
    }
  }

  Future<void> _printReport(BuildContext context, AppLocalizations? loc) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  loc?.translate('customerMetrics') ?? 'Customer Metrics',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(loc?.translate('analyzeCustomerBehavior') ?? 'Customer behavior and engagement patterns'),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.translate('errorPrintingReport') ?? 'Error printing report'}: $e')),
        );
      }
    }
  }
}


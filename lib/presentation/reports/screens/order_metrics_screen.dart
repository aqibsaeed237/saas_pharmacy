import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/localization/app_localizations.dart';

/// Order Metrics screen with charts
class OrderMetricsScreen extends StatelessWidget {
  const OrderMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('orderMetrics') ?? 'Order Metrics'),
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
                          Icons.shopping_cart,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc?.translate('orderMetrics') ?? 'Order Metrics',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc?.translate('monitorOrderTrends') ?? 'Monitor order trends and operational efficiency.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    // Mock chart
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 40,
                              title: loc?.translate('completed') ?? 'Completed',
                              color: Colors.green,
                            ),
                            PieChartSectionData(
                              value: 30,
                              title: loc?.translate('ongoing') ?? 'Ongoing',
                              color: Colors.yellow,
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: loc?.translate('scheduled') ?? 'Scheduled',
                              color: Colors.blue,
                            ),
                            PieChartSectionData(
                              value: 10,
                              title: loc?.translate('cancelled') ?? 'Cancelled',
                              color: Colors.red,
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
      await Share.share('${loc?.translate('orderMetrics') ?? 'Order Metrics'} Report\n\nGenerated from Pharmacy POS');
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
                  loc?.translate('orderMetrics') ?? 'Order Metrics',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(loc?.translate('monitorOrderTrends') ?? 'Order trends and operational efficiency'),
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


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/loading_widget.dart';

/// Sales and Revenue Metrics screen with charts
class SalesRevenueMetricsScreen extends StatefulWidget {
  const SalesRevenueMetricsScreen({super.key});

  @override
  State<SalesRevenueMetricsScreen> createState() => _SalesRevenueMetricsScreenState();
}

class _SalesRevenueMetricsScreenState extends State<SalesRevenueMetricsScreen> {
  String _selectedPeriod = 'weekly';
  bool _isLoading = false;

  // Mock data for charts
  final List<Map<String, dynamic>> _salesData = [
    {'week': 'Week 1', 'previous': 2.0, 'current': 3.0},
    {'week': 'Week 2', 'previous': 3.5, 'current': 4.0},
    {'week': 'Week 3', 'previous': 4.0, 'current': 5.5},
    {'week': 'Week 4', 'previous': 3.0, 'current': 4.5},
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('salesAndRevenueMetrics') ?? 'Sales and Revenue Metrics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Period selector
          DropdownButton<String>(
            value: _selectedPeriod,
            items: ['daily', 'weekly', 'monthly'].map((period) {
              return DropdownMenuItem(
                value: period,
                child: Text(loc?.translate(period) ?? period),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPeriod = value);
              }
            },
          ),
          const SizedBox(width: 8),
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: loc?.translate('shareReport') ?? 'Share Report',
          ),
          // Print button
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReport,
            tooltip: loc?.translate('printReport') ?? 'Print Report',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total Sales Card
                  _buildTotalSalesCard(context, loc),
                  const SizedBox(height: 24),
                  // Total Orders Card
                  _buildTotalOrdersCard(context, loc),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalSalesCard(BuildContext context, AppLocalizations? loc) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  loc?.translate('totalSales') ?? 'Total Sales',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              loc?.translate('comparisonByWeekly') ?? 'Comparison by Weekly',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              children: [
                _buildLegendItem(
                  context,
                  loc?.translate('previousValue') ?? 'Previous Value',
                  Colors.grey,
                ),
                const SizedBox(width: 16),
                _buildLegendItem(
                  context,
                  loc?.translate('currentValue') ?? 'Current Value',
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Chart
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 6,
                  barTouchData: BarTouchData(
                    enabled: false,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _salesData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _salesData[index]['week'],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _salesData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['previous'],
                          color: Colors.grey,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: data['current'],
                          color: Colors.blue,
                          width: 12,
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalOrdersCard(BuildContext context, AppLocalizations? loc) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  loc?.translate('totalOrders') ?? 'Total Number of Orders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              loc?.translate('comparisonByWeekly') ?? 'Comparison by Weekly',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              children: [
                _buildLegendItem(
                  context,
                  loc?.translate('previous') ?? 'Previous',
                  Colors.yellow,
                ),
                const SizedBox(width: 16),
                _buildLegendItem(
                  context,
                  loc?.translate('current') ?? 'Current',
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Chart
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 6,
                  barTouchData: BarTouchData(
                    enabled: false,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _salesData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _salesData[index]['week'],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _salesData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['previous'],
                          color: Colors.yellow,
                          width: 12,
                        ),
                        BarChartRodData(
                          toY: data['current'],
                          color: Colors.purple,
                          width: 12,
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _shareReport() async {
    final loc = AppLocalizations.of(context);
    try {
      await Share.share('${loc?.translate('salesAndRevenueMetrics') ?? 'Sales and Revenue Metrics'} Report\n\nGenerated from Pharmacy POS');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.translate('errorSharingReport') ?? 'Error sharing report'}: $e')),
        );
      }
    }
  }

  Future<void> _printReport() async {
    final loc = AppLocalizations.of(context);
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  loc?.translate('salesAndRevenueMetrics') ?? 'Sales and Revenue Metrics',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text('${loc?.translate('totalSales') ?? 'Total Sales'}: ${loc?.translate('comparisonByWeekly') ?? 'Comparison by Weekly'}'),
                pw.SizedBox(height: 10),
                pw.Text('${loc?.translate('totalOrders') ?? 'Total Orders'}: ${loc?.translate('comparisonByWeekly') ?? 'Comparison by Weekly'}'),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.translate('errorPrintingReport') ?? 'Error printing report'}: $e')),
        );
      }
    }
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Completed sales tab
class CompletedSalesTab extends StatelessWidget {
  const CompletedSalesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    // Mock completed sales
    final completedSales = <Map<String, dynamic>>[
      {
        'id': 'sale2',
        'invoiceNumber': 'INV-002',
        'customerName': 'Jane Smith',
        'total': 250.0,
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 'sale3',
        'invoiceNumber': 'INV-003',
        'customerName': 'Bob Johnson',
        'total': 180.0,
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
    
    if (completedSales.isEmpty) {
      return Center(
        child: Text(loc?.translate('noCompletedSales') ?? 'No completed sales'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedSales.length,
      itemBuilder: (context, index) {
        final sale = completedSales[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(
              sale['invoiceNumber'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale['customerName'] ?? ''),
                Text(
                  DateFormat('MMM dd, yyyy').format(sale['createdAt']),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Text(
              CurrencyFormatter.format(sale['total']),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                  ),
            ),
            onTap: () {
              context.pushNamed('saleSummary', pathParameters: {'id': sale['id']});
            },
          ),
        );
      },
    );
  }
}


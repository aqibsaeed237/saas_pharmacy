import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Cancelled sales tab
class CancelledSalesTab extends StatelessWidget {
  const CancelledSalesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    // Mock cancelled sales
    final cancelledSales = <Map<String, dynamic>>[
      {
        'id': 'sale4',
        'invoiceNumber': 'INV-004',
        'customerName': 'Alice Brown',
        'total': 120.0,
        'reason': 'Customer request',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];
    
    if (cancelledSales.isEmpty) {
      return Center(
        child: Text(loc?.translate('noCancelledSales') ?? 'No cancelled sales'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cancelledSales.length,
      itemBuilder: (context, index) {
        final sale = cancelledSales[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
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
                if (sale['reason'] != null)
                  Text(
                    '${loc?.translate('reason') ?? 'Reason'}: ${sale['reason']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                  ),
              ],
            ),
            trailing: Text(
              CurrencyFormatter.format(sale['total']),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
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


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/sale.dart';

/// Ongoing sales tab
class OngoingSalesTab extends StatelessWidget {
  const OngoingSalesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    // Mock ongoing sales (partial payments, pending)
    final ongoingSales = <Map<String, dynamic>>[
      {
        'id': 'sale1',
        'invoiceNumber': 'INV-001',
        'customerName': 'John Doe',
        'total': 150.0,
        'paid': 50.0,
        'remaining': 100.0,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];
    
    if (ongoingSales.isEmpty) {
      return Center(
        child: Text(loc?.translate('noOngoingSales') ?? 'No ongoing sales'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ongoingSales.length,
      itemBuilder: (context, index) {
        final sale = ongoingSales[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.pending_actions, color: Colors.orange),
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
                const SizedBox(height: 4),
                Text(
                  '${loc?.translate('paid') ?? 'Paid'}: ${CurrencyFormatter.format(sale['paid'])} / ${loc?.translate('remaining') ?? 'Remaining'}: ${CurrencyFormatter.format(sale['remaining'])}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                ),
              ],
            ),
            trailing: Text(
              CurrencyFormatter.format(sale['total']),
              style: Theme.of(context).textTheme.titleMedium,
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


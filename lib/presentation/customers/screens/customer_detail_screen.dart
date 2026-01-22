import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../bloc/customer_bloc.dart';

/// Customer detail screen with purchase history
class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomerHistory(widget.customerId));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    // Mock customer data - in production, load from BLoC
    final customer = <String, dynamic>{
      'id': widget.customerId,
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+1234567890',
      'address': '123 Main St, New York, USA',
      'totalPurchases': 3,
      'totalSpent': 459.75,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('customerDetails') ?? 'Customer Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed('customerEdit', pathParameters: {'customerId': widget.customerId});
            },
            tooltip: loc?.translate('edit') ?? 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            customer['name'][0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer['name'] as String,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (customer['email'] != null)
                                Text(
                                  customer['email'] as String,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              if (customer['phone'] != null)
                                Text(
                                  customer['phone'] as String,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (customer['address'] != null)
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(customer['address'] as String),
                        contentPadding: EdgeInsets.zero,
                      ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            loc?.translate('totalPurchases') ?? 'Total Purchases',
                            '${customer['totalPurchases']}',
                            Icons.shopping_bag,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            loc?.translate('totalSpent') ?? 'Total Spent',
                            CurrencyFormatter.format(customer['totalSpent'] as double),
                            Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Purchase History
            Text(
              loc?.translate('purchaseHistory') ?? 'Purchase History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CustomerHistoryLoaded) {
                  if (state.history.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                loc?.translate('noPurchaseHistory') ?? 'No purchase history',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: state.history.map((purchase) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.receipt,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            purchase['invoiceNumber'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(purchase['date'] as DateTime),
                              ),
                              Text(
                                '${purchase['items']} ${loc?.translate('items') ?? 'items'}',
                              ),
                            ],
                          ),
                          trailing: Text(
                            CurrencyFormatter.format(purchase['total'] as double),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          onTap: () {
                            context.pushNamed(
                              'saleSummary',
                              pathParameters: {'saleId': purchase['id']},
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/empty_view.dart';

/// Purchase list screen
class PurchaseListScreen extends StatelessWidget {
  const PurchaseListScreen({super.key});

  // Mock data
  final List<Map<String, dynamic>> mockPurchases = const [
    {
      'id': '1',
      'supplier': 'ABC Pharmaceuticals',
      'date': '2024-01-15',
      'total': 1250.50,
      'status': 'completed',
    },
    {
      'id': '2',
      'supplier': 'XYZ Medical',
      'date': '2024-01-10',
      'total': 850.00,
      'status': 'pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: mockPurchases.isEmpty
          ? const EmptyView(
              message: 'No purchases found',
              icon: Icons.shopping_cart_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockPurchases.length,
              itemBuilder: (context, index) {
                final purchase = mockPurchases[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        purchase['status'] == 'completed'
                            ? Icons.check_circle
                            : Icons.pending,
                      ),
                    ),
                    title: Text(purchase['supplier']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${purchase['date']}'),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            purchase['status'],
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: purchase['status'] == 'completed'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.format(purchase['total']),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 20),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              context.go('/purchases/edit/${purchase['id']}');
                            } else if (value == 'view') {
                              // View purchase details
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // View purchase details
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/purchases/add'),
        icon: const Icon(Icons.add),
        label: const Text('New Purchase'),
      ),
    );
  }
}


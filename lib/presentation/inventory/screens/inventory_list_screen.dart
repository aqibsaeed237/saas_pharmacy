import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/app_button.dart';

/// Inventory list screen
class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

  // Mock data
  final List<Map<String, dynamic>> mockInventory = const [
    {
      'productName': 'Paracetamol 500mg',
      'batchNumber': 'BATCH001',
      'quantity': 150,
      'remainingQuantity': 50,
      'expiryDate': '2024-12-31',
      'costPrice': 3.50,
      'isExpiringSoon': false,
      'isExpired': false,
    },
    {
      'productName': 'Aspirin 100mg',
      'batchNumber': 'BATCH002',
      'quantity': 200,
      'remainingQuantity': 5,
      'expiryDate': '2024-06-15',
      'costPrice': 2.00,
      'isExpiringSoon': true,
      'isExpired': false,
    },
    {
      'productName': 'Ibuprofen 200mg',
      'batchNumber': 'BATCH003',
      'quantity': 100,
      'remainingQuantity': 0,
      'expiryDate': '2024-01-01',
      'costPrice': 4.00,
      'isExpiringSoon': false,
      'isExpired': true,
    },
  ];

  Color _getExpiryColor(bool isExpired, bool isExpiringSoon) {
    if (isExpired) return Colors.red;
    if (isExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('inventory') ?? 'Inventory'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: mockInventory.isEmpty
          ? EmptyView(
              message: AppLocalizations.of(context)?.translate('noInventoryItems') ?? 'No inventory items found',
              icon: Icons.inventory_2_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockInventory.length,
              itemBuilder: (context, index) {
                final item = mockInventory[index];
                final expiryColor = _getExpiryColor(
                  item['isExpired'] as bool,
                  item['isExpiringSoon'] as bool,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      // Navigate to inventory detail screen
                      context.goNamed('inventoryDetail', pathParameters: {'batchId': item['batchNumber'] as String});
                    },
                    leading: CircleAvatar(
                      backgroundColor: expiryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.inventory_2,
                        color: expiryColor,
                      ),
                    ),
                    title: Text(item['productName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${AppLocalizations.of(context)?.translate('batch') ?? 'Batch'}: ${item['batchNumber']}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                'Qty: ${item['remainingQuantity']}/${item['quantity']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 8),
                            if (item['remainingQuantity'] as int < 10)
                              Chip(
                                label: Text(
                                  AppLocalizations.of(context)?.translate('lowStock') ?? 'Low Stock',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.orange.withOpacity(0.2),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: expiryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${AppLocalizations.of(context)?.translate('expiryDate') ?? 'Expires'}: ${item['expiryDate']}',
                              style: TextStyle(color: expiryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)?.translate('edit') ?? 'Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'adjust',
                          child: Row(
                            children: [
                              const Icon(Icons.tune, size: 20),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)?.translate('adjustStock') ?? 'Adjust Stock'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Navigate to edit screen
                          context.go('/inventory/edit/${item['batchNumber']}');
                        } else if (value == 'adjust') {
                          // Show adjust stock dialog
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('inventoryAdd'),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)?.translate('addStock') ?? 'Add Stock'),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc?.translate('filterInventory') ?? 'Filter Inventory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.warning),
              title: Text(loc?.translate('lowStock') ?? 'Low Stock'),
              onTap: () {
                Navigator.pop(context);
                // Apply low stock filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(loc?.translate('expiringSoon') ?? 'Expiring Soon'),
              onTap: () {
                Navigator.pop(context);
                // Apply expiring soon filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(loc?.translate('expired') ?? 'Expired'),
              onTap: () {
                Navigator.pop(context);
                // Apply expired filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: Text(loc?.translate('clearFilters') ?? 'Clear Filters'),
              onTap: () {
                Navigator.pop(context);
                // Clear all filters
              },
            ),
          ],
        ),
      ),
    );
  }
}


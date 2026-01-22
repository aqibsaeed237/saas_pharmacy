import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_button.dart';

/// Inventory detail screen with actionable options
class InventoryDetailScreen extends StatelessWidget {
  final String batchId;

  const InventoryDetailScreen({super.key, required this.batchId});

  // Mock data - in real app, fetch from BLoC
  Map<String, dynamic> get _mockInventory => {
        'productName': 'Paracetamol 500mg',
        'batchNumber': 'BATCH001',
        'quantity': 150,
        'remainingQuantity': 50,
        'expiryDate': '2024-12-31',
        'costPrice': 3.50,
        'sellingPrice': 5.99,
        'isExpiringSoon': false,
        'isExpired': false,
        'supplier': 'ABC Pharmaceuticals',
        'purchaseDate': '2024-01-15',
        'location': 'Main Store',
      };

  Color _getExpiryColor(bool isExpired, bool isExpiringSoon) {
    if (isExpired) return Colors.red;
    if (isExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final item = _mockInventory;
    final expiryColor = _getExpiryColor(
      item['isExpired'] as bool,
      item['isExpiringSoon'] as bool,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('inventoryDetails') ?? 'Inventory Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
            actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              context.goNamed('inventoryEdit', pathParameters: {'id': batchId});
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              final loc = AppLocalizations.of(context);
              return [
                PopupMenuItem(
                  value: 'adjust',
                  child: Row(
                    children: [
                      const Icon(Icons.tune, size: 20),
                      const SizedBox(width: 8),
                      Text(loc?.translate('adjustStock') ?? 'Adjust Stock'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'transfer',
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 20),
                      const SizedBox(width: 8),
                      Text(loc?.translate('transferStock') ?? 'Transfer Stock'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      const Icon(Icons.print, size: 20),
                      const SizedBox(width: 8),
                      Text(loc?.translate('printLabel') ?? 'Print Label'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(loc?.translate('delete') ?? 'Delete', style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'adjust':
                  _showAdjustStockDialog(context);
                  break;
                case 'transfer':
                  _showTransferStockDialog(context);
                  break;
                case 'print':
                  _printLabel(context);
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: expiryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.inventory_2,
                            size: 30,
                            color: expiryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['productName'],
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Batch: ${item['batchNumber']}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(
                      context,
                      AppLocalizations.of(context)?.translate('remainingQuantity') ?? 'Remaining Quantity',
                      '${item['remainingQuantity']} / ${item['quantity']} ${AppLocalizations.of(context)?.translate('quantity')?.toLowerCase() ?? 'units'}',
                      Icons.inventory,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      AppLocalizations.of(context)?.translate('costPrice') ?? 'Cost Price',
                      CurrencyFormatter.format(item['costPrice']),
                      Icons.monetization_on,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      AppLocalizations.of(context)?.translate('sellingPrice') ?? 'Selling Price',
                      CurrencyFormatter.format(item['sellingPrice']),
                      Icons.attach_money,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Expiry Info Card
            Card(
              color: expiryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: expiryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.translate('expiryDate') ?? 'Expiry Date',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['expiryDate'],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: expiryColor),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        item['isExpired']
                            ? (AppLocalizations.of(context)?.translate('expired') ?? 'Expired')
                            : item['isExpiringSoon']
                                ? (AppLocalizations.of(context)?.translate('expiringSoon') ?? 'Expiring Soon')
                                : (AppLocalizations.of(context)?.translate('valid') ?? 'Valid'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: expiryColor,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.translate('additionalInformation') ?? 'Additional Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      AppLocalizations.of(context)?.translate('supplier') ?? 'Supplier',
                      item['supplier'],
                      Icons.local_shipping,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      AppLocalizations.of(context)?.translate('purchaseDate') ?? 'Purchase Date',
                      item['purchaseDate'],
                      Icons.shopping_cart,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      AppLocalizations.of(context)?.translate('location') ?? 'Location',
                      item['location'],
                      Icons.location_on,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            AppButton(
              label: AppLocalizations.of(context)?.translate('adjustStock') ?? 'Adjust Stock',
              onPressed: () => _showAdjustStockDialog(context),
              icon: Icons.tune,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: AppLocalizations.of(context)?.translate('transferStock') ?? 'Transfer Stock',
              onPressed: () => _showTransferStockDialog(context),
              icon: Icons.swap_horiz,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: AppLocalizations.of(context)?.translate('printLabel') ?? 'Print Label',
              onPressed: () => _printLabel(context),
              icon: Icons.print,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAdjustStockDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc?.translate('adjustStock') ?? 'Adjust Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: loc?.translate('newQuantity') ?? 'New Quantity',
                hintText: loc?.translate('quantity') ?? 'Enter quantity',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle adjust stock
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc?.translate('stockAdjusted') ?? 'Stock adjusted successfully')),
              );
            },
            child: Text(loc?.translate('adjustStock') ?? 'Adjust'),
          ),
        ],
      ),
    );
  }

  void _showTransferStockDialog(BuildContext context) {
    final quantityController = TextEditingController();
    String? selectedLocation;
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc?.translate('transferStock') ?? 'Transfer Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: loc?.translate('quantityToTransfer') ?? 'Quantity to Transfer',
                hintText: loc?.translate('quantity') ?? 'Enter quantity',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: loc?.translate('transferTo') ?? 'Transfer To',
              ),
              items: ['Main Store', 'Branch 1', 'Branch 2'].map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) => selectedLocation = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle transfer stock
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc?.translate('stockTransferred') ?? 'Stock transferred successfully')),
              );
            },
            child: Text(loc?.translate('transferStock') ?? 'Transfer'),
          ),
        ],
      ),
    );
  }

  void _printLabel(BuildContext context) {
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc?.translate('printingLabel') ?? 'Printing label...')),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc?.translate('deleteInventory') ?? 'Delete Inventory'),
        content: Text(loc?.translate('deleteInventoryConfirmation') ?? 'Are you sure you want to delete this inventory item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc?.translate('inventoryDeleted') ?? 'Inventory deleted')),
              );
            },
            child: Text(loc?.translate('delete') ?? 'Delete', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/sale.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';

void _showClearCartConfirmation(
  BuildContext context,
  AppLocalizations? loc,
  VoidCallback onConfirm,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(loc?.translate('clearCartConfirm') ?? 'Clear all items?'),
      content: Text(loc?.translate('clearCartConfirmMessage') ?? 'This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(loc?.translate('cancel') ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
          child: Text(loc?.translate('clearCart') ?? 'Clear cart'),
        ),
      ],
    ),
  );
}

/// Draggable cart bottom sheet - drag to expand/collapse
class CartBottomSheet extends StatelessWidget {
  final SaleCartState saleState;
  final AppLocalizations? loc;
  final VoidCallback onProcessSale;
  final VoidCallback? onClearCart;

  const CartBottomSheet({
    super.key,
    required this.saleState,
    required this.loc,
    required this.onProcessSale,
    this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.38,
      maxChildSize: 0.9,
      builder: (context, scrollController) => LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 280;
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle
                Padding(
                  padding: EdgeInsets.only(top: isCompact ? 8 : 12, bottom: isCompact ? 4 : 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Cart header with Clear cart
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: isCompact ? 4 : 8),
                  child: Row(
                    children: [
                  Icon(
                    Icons.shopping_cart_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${loc?.translate('cart') ?? 'Cart'} (${saleState.items.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onClearCart != null)
                    TextButton.icon(
                      icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                      label: Text(
                        loc?.translate('clearCart') ?? 'Clear cart',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                      onPressed: () => _showClearCartConfirmation(context, loc, onClearCart!),
                    ),
                  ],
                ),
                ),
                const Divider(height: 1),
                // Cart items - quantity and price on row below each item
                Expanded(
              child: saleState.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 56,
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc?.translate('cartEmpty') ?? 'Cart is empty',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc?.translate('addProductsHint') ?? 'Tap a product above to add items',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      itemCount: saleState.items.length,
                      itemBuilder: (context, index) {
                        final item = saleState.items[index];
                        return _CartSheetItem(item: item, loc: loc);
                      },
                    ),
                ),
                // Total + Process Sale - fixed at bottom
                Container(
                  padding: EdgeInsets.fromLTRB(20, isCompact ? 8 : 16, 20, isCompact ? 12 : 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc?.translate('total') ?? 'Total',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(saleState.total),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 8 : 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: saleState.items.isEmpty ? null : onProcessSale,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            loc?.translate('processSale') ?? 'Process Sale',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartSheetItem extends StatelessWidget {
  final SaleItem item;
  final AppLocalizations? loc;

  const _CartSheetItem({required this.item, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 22, color: Theme.of(context).colorScheme.error),
                  onPressed: () {
                    context.read<SaleBloc>().add(RemoveItemFromCart(item.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc?.translate('itemRemoved') ?? 'Item removed'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                  tooltip: loc?.translate('itemRemoved') ?? 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _QuantityBtn(
                      icon: Icons.remove,
                      onPressed: () {
                        if (item.quantity > 1) {
                          context.read<SaleBloc>().add(
                            UpdateItemQuantity(itemId: item.id, quantity: item.quantity - 1),
                          );
                        } else {
                          context.read<SaleBloc>().add(RemoveItemFromCart(item.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc?.translate('itemRemoved') ?? 'Item removed'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _QuantityBtn(
                      icon: Icons.add,
                      onPressed: () {
                        context.read<SaleBloc>().add(
                          UpdateItemQuantity(itemId: item.id, quantity: item.quantity + 1),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  '${item.quantity} × ${CurrencyFormatter.format(item.unitPrice)} = ${CurrencyFormatter.format(item.total)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

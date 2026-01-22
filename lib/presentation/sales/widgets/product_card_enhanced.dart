import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/product.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';

/// Enhanced product card with stock status, variants, and quick add
class ProductCardEnhanced extends StatelessWidget {
  final Product product;
  final int? stockOnHand; // SOH
  final String? productType; // 'OTC' or 'RX'
  final List<Product>? variants; // Product variants (sizes, strengths)
  final bool isScriptWaiting; // For pharmacy scripts
  final Function(Product, int)? onAddToCart;

  const ProductCardEnhanced({
    super.key,
    required this.product,
    this.stockOnHand,
    this.productType,
    this.variants,
    this.isScriptWaiting = false,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isLowStock = stockOnHand != null && stockOnHand! < 10;
    final isOutOfStock = stockOnHand != null && stockOnHand! == 0;
    
    return Card(
      elevation: 2,
      color: isScriptWaiting
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: () {
          if (variants != null && variants!.isNotEmpty) {
            _showVariantDialog(context);
          } else {
            _quickAddToCart(context, 1);
          }
        },
        onLongPress: () => _showQuantityDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product type badge
              if (productType != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: productType == 'RX'
                            ? Colors.red.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        productType!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: productType == 'RX' ? Colors.red : Colors.blue,
                        ),
                      ),
                    ),
                    if (isScriptWaiting)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Builder(
                          builder: (context) {
                            final loc = AppLocalizations.of(context);
                            return Text(
                              loc?.translate('script') ?? 'SCRIPT',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 4),
              
              // Product image
              Center(
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.medication, size: 40);
                        },
                      )
                    : const Icon(Icons.medication, size: 40),
              ),
              const SizedBox(height: 8),
              
              // Product name
              Expanded(
                child: Text(
                  product.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 4),
              
              // Price
              Text(
                CurrencyFormatter.format(product.price),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              // Stock status
              if (stockOnHand != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOutOfStock
                          ? Icons.cancel
                          : isLowStock
                              ? Icons.warning
                              : Icons.check_circle,
                      size: 12,
                      color: isOutOfStock
                          ? Colors.red
                          : isLowStock
                              ? Colors.orange
                              : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SOH: $stockOnHand',
                      style: TextStyle(
                        fontSize: 10,
                        color: isOutOfStock
                            ? Colors.red
                            : isLowStock
                                ? Colors.orange
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Barcode/SKU
              if (product.barcode != null || product.sku != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    product.barcode ?? product.sku ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              
              // Variant indicator
              if (variants != null && variants!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.layers,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${variants!.length} ${loc?.translate('variants') ?? 'variants'}',
                        style: TextStyle(
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _quickAddToCart(BuildContext context, int quantity) {
    if (onAddToCart != null) {
      onAddToCart!(product, quantity);
    } else {
      // Use BlocProvider.of as fallback
      BlocProvider.of<SaleBloc>(context).add(
            AddItemToCart(
              productId: product.id,
              productName: product.name,
              price: product.price,
              quantity: quantity,
            ),
          );
    }
  }

  void _showQuantityDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final quantityController = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${loc?.translate('price') ?? 'Price'}: ${CurrencyFormatter.format(product.price)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (stockOnHand != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${loc?.translate('stockOnHand') ?? 'Stock'}: $stockOnHand',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: loc?.translate('quantity') ?? 'Quantity',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 2, 5, 10, 20].map((qty) {
                return ElevatedButton(
                  onPressed: () {
                    quantityController.text = qty.toString();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 40),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('$qty'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 1;
              if (quantity > 0) {
                _quickAddToCart(context, quantity);
                Navigator.pop(context);
              }
            },
            child: Text(loc?.translate('add') ?? 'Add'),
          ),
        ],
      ),
    );
  }

  void _showVariantDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${loc?.translate('selectVariant') ?? 'Select Variant'} - ${product.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: variants!.length,
            itemBuilder: (context, index) {
              final variant = variants![index];
              return ListTile(
                leading: const Icon(Icons.medication),
                title: Text(variant.name),
                subtitle: Text('${CurrencyFormatter.format(variant.price)}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (onAddToCart != null) {
                      onAddToCart!(variant, 1);
                    } else {
                      BlocProvider.of<SaleBloc>(context).add(
                            AddItemToCart(
                              productId: variant.id,
                              productName: variant.name,
                              price: variant.price,
                              quantity: 1,
                            ),
                          );
                    }
                    Navigator.pop(context);
                  },
                  child: Text(loc?.translate('add') ?? 'Add'),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
        ],
      ),
    );
  }
}


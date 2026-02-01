import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/product.dart';
import '../../products/bloc/product_bloc.dart';
import '../../products/bloc/product_event.dart';
import '../../products/bloc/product_state.dart';
import '../../customers/bloc/customer_bloc.dart';

/// Universal search bar with predictive search and customer search
class UniversalSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final Function(String)? onProductSelected;
  final Function(String)? onCustomerSelected;
  final bool showAdvancedFilters;

  const UniversalSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onProductSelected,
    this.onCustomerSelected,
    this.showAdvancedFilters = false,
  });

  @override
  State<UniversalSearchBar> createState() => _UniversalSearchBarState();
}

class _UniversalSearchBarState extends State<UniversalSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  bool _isCustomerSearch = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text.trim();
    
    // Check if customer search (starts with /)
    if (query.startsWith('/')) {
      _isCustomerSearch = true;
      final customerQuery = query.substring(1).trim();
      if (customerQuery.isNotEmpty) {
        context.read<CustomerBloc>().add(LoadCustomers(search: customerQuery));
      }
    } else {
      _isCustomerSearch = false;
      if (query.isNotEmpty) {
        context.read<ProductBloc>().add(LoadProducts(search: query));
        setState(() => _showSuggestions = true);
      } else {
        setState(() => _showSuggestions = false);
      }
    }
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Ctrl+S or Cmd+S for advanced filters
      final isModifierPressed = HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;
      if ((event.logicalKey == LogicalKeyboardKey.keyS) && isModifierPressed) {
        _showAdvancedFilters();
      }
    }
  }

  void _showAdvancedFilters() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc?.translate('advancedFilters') ?? 'Advanced Filters'),
        content: Text(loc?.translate('advancedFilterOptionsComingSoon') ?? 'Advanced filter options coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.translate('close') ?? 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyPress,
      child: Column(
        children: [
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: _isCustomerSearch
                  ? (loc?.translate('searchCustomers') ?? 'Search customers (use / for customer search)')
                  : (loc?.translate('searchProductsBarcode') ?? 'Search products, barcode, SKU...'),
              prefixIcon: Icon(_isCustomerSearch ? Icons.person_search : Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onSearch('');
                        setState(() {
                          _showSuggestions = false;
                          _isCustomerSearch = false;
                        });
                      },
                    ),
                  if (widget.showAdvancedFilters)
                    IconButton(
                      icon: const Icon(Icons.tune),
                      tooltip: 'Advanced Filters (Ctrl+S)',
                      onPressed: _showAdvancedFilters,
                    ),
                ],
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.onSearch(value);
              _onSearchChanged();
            },
            onSubmitted: (value) {
              if (_isCustomerSearch) {
                final customerState = BlocProvider.of<CustomerBloc>(context).state;
                if (customerState is CustomersLoaded && customerState.customers.isNotEmpty) {
                  final customer = customerState.customers.first;
                  widget.onCustomerSelected?.call(customer.id);
                }
              } else {
                final productState = BlocProvider.of<ProductBloc>(context).state;
                if (productState is ProductsLoaded && productState.products.isNotEmpty) {
                  final product = productState.products.first;
                  widget.onProductSelected?.call(product.id);
                }
              }
            },
          ),
          // Predictive search suggestions
          if (_showSuggestions)
            _isCustomerSearch
                ? BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, customerState) {
                      if (customerState is CustomersLoaded && customerState.customers.isNotEmpty) {
                        return _buildSuggestionsList(
                          context,
                          customerState.customers.map((c) => {
                            'id': c.id,
                            'name': c.name,
                            'phone': c.phone,
                            'email': c.email,
                          }).toList(),
                          isCustomer: true,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  )
                : BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, productState) {
                      if (productState is ProductsLoaded && productState.products.isNotEmpty) {
                        return _buildSuggestionsList(
                          context,
                          productState.products,
                          isCustomer: false,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, List<dynamic> items, {required bool isCustomer}) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length > 10 ? 10 : items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (isCustomer) {
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(item['name'] ?? ''),
              subtitle: Text(item['phone'] ?? item['email'] ?? ''),
              onTap: () {
                widget.controller.text = item['name'] ?? '';
                widget.onCustomerSelected?.call(item['id']);
                setState(() => _showSuggestions = false);
              },
            );
          } else {
            final product = item as Product;
            return ListTile(
              leading: const Icon(Icons.medication),
              title: Text(product.name),
              subtitle: Text('${product.barcode ?? product.sku ?? ''} - ${product.price}'),
              onTap: () {
                widget.controller.text = product.name;
                widget.onProductSelected?.call(product.id);
                setState(() => _showSuggestions = false);
              },
            );
          }
        },
      ),
    );
  }
}


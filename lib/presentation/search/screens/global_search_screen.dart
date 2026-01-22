import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/customer.dart';
import '../bloc/search_bloc.dart';

/// Global search screen
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  final _debounceTimer = ValueNotifier<Duration?>(null);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.read<SearchBloc>().add(ClearSearch());
    } else {
      // Debounce search
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_searchController.text.trim() == query) {
          context.read<SearchBloc>().add(PerformSearch(query));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: loc?.translate('search') ?? 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<SearchBloc>().add(ClearSearch());
              },
            ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc?.translate('searchHint') ?? 'Search for products, sales, customers...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            );
          }
          
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is SearchLoaded) {
            if (state.results.isEmpty) {
              return Center(
                child: Text(loc?.translate('noResults') ?? 'No results found'),
              );
            }
            
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.results.products.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    loc?.translate('products') ?? 'Products',
                    state.results.products.length,
                  ),
                  ...state.results.products.map((product) => _buildProductTile(context, product, loc)),
                  const SizedBox(height: 16),
                ],
                if (state.results.sales.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    loc?.translate('sales') ?? 'Sales',
                    state.results.sales.length,
                  ),
                  ...state.results.sales.map((sale) => _buildSaleTile(context, sale, loc)),
                  const SizedBox(height: 16),
                ],
                if (state.results.customers.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    loc?.translate('customers') ?? 'Customers',
                    state.results.customers.length,
                  ),
                  ...state.results.customers.map((customer) => _buildCustomerTile(context, customer, loc)),
                ],
              ],
            );
          }
          
          return Center(
            child: Text(loc?.translate('error') ?? 'Error'),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product, AppLocalizations? loc) {
    return ListTile(
      leading: const Icon(Icons.inventory_2),
      title: Text(product.name),
      subtitle: Text(product.barcode ?? product.sku ?? ''),
      trailing: Text(
        '\$${product.price.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () {
        context.pushNamed('productsEdit', pathParameters: {'id': product.id});
      },
    );
  }

  Widget _buildSaleTile(BuildContext context, Sale sale, AppLocalizations? loc) {
    return ListTile(
      leading: const Icon(Icons.receipt),
      title: Text(sale.invoiceNumber),
      subtitle: Text(sale.customerName ?? ''),
      trailing: Text(
        '\$${sale.total.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () {
        context.pushNamed('saleSummary', pathParameters: {'id': sale.id});
      },
    );
  }

  Widget _buildCustomerTile(BuildContext context, Customer customer, AppLocalizations? loc) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(customer.name),
      subtitle: Text(customer.phone ?? customer.email ?? ''),
      onTap: () {
        context.pushNamed('customerDetail', pathParameters: {'id': customer.id});
      },
    );
  }
}


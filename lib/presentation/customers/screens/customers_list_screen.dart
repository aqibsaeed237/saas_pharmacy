import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/router/app_router.dart';
import '../bloc/customer_bloc.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_view.dart';

/// Customers list screen - Admin only
class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<CustomerBloc>().add(LoadCustomers(search: query.isEmpty ? null : query));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('customers') ?? 'Customers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Check if user is admin
          if (AppRouter.currentUser?.role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.pushNamed('customerAdd'),
              tooltip: loc?.translate('addCustomer') ?? 'Add Customer',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc?.translate('searchCustomers') ?? 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: _handleSearch,
            ),
          ),
          
          // Customers list
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CustomerError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CustomerBloc>().add(const LoadCustomers());
                          },
                          child: Text(loc?.translate('retry') ?? 'Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is CustomersLoaded) {
                  if (state.customers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc?.translate('noCustomers') ?? 'No customers found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc?.translate('addFirstCustomer') ?? 'Add your first customer to get started',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: 8,
                    ),
                    itemCount: state.customers.length,
                    itemBuilder: (context, index) {
                      final customer = state.customers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customer.phone != null)
                                Text(customer.phone!),
                              if (customer.email != null)
                                Text(customer.email!),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.history),
                                onPressed: () {
                                  context.pushNamed(
                                    'customerDetail',
                                    pathParameters: {'customerId': customer.id},
                                  );
                                },
                                tooltip: loc?.translate('viewHistory') ?? 'View History',
                              ),
                              if (AppRouter.currentUser?.role == UserRole.admin)
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit, size: 20),
                                          const SizedBox(width: 8),
                                          Text(loc?.translate('edit') ?? 'Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete, color: Colors.red, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            loc?.translate('delete') ?? 'Delete',
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      context.pushNamed(
                                        'customerEdit',
                                        pathParameters: {'customerId': customer.id},
                                      );
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(context, customer.id, customer.name);
                                    }
                                  },
                                ),
                            ],
                          ),
                          onTap: () {
                            context.pushNamed(
                              'customerDetail',
                              pathParameters: {'customerId': customer.id},
                            );
                          },
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AppRouter.currentUser?.role == UserRole.admin
          ? FloatingActionButton.extended(
              onPressed: () => context.pushNamed('customerAdd'),
              icon: const Icon(Icons.add),
              label: Text(loc?.translate('addCustomer') ?? 'Add Customer'),
            )
          : null,
    );
  }

  void _showDeleteDialog(BuildContext context, String customerId, String customerName) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc?.translate('deleteCustomer') ?? 'Delete Customer'),
        content: Text(
          '${loc?.translate('deleteCustomerConfirmation') ?? 'Are you sure you want to delete'} $customerName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CustomerBloc>().add(DeleteCustomer(customerId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc?.translate('customerDeleted') ?? 'Customer deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(loc?.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );
  }
}


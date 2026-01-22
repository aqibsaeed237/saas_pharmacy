import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/store_bloc.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/app_text_field.dart';

/// Store selection screen
class StoreSelectionScreen extends StatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StoreBloc>().add(const LoadStores());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<StoreBloc>().add(LoadStores(search: query.isEmpty ? null : query));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('selectStore') ?? 'Select Store'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add store screen
              // context.pushNamed(AppRoutes.storeAdd);
            },
            tooltip: loc?.translate('newStore') ?? 'New Store',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppTextField(
              controller: _searchController,
              label: loc?.translate('searchStores') ?? 'Search stores...',
              hint: loc?.translate('searchStores') ?? 'Search stores...',
              prefixIcon: Icons.search,
              onChanged: _handleSearch,
            ),
          ),
          // Store count and new store button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<StoreBloc, StoreState>(
                  builder: (context, state) {
                    final count = state is StoresLoaded ? state.stores.length : 0;
                    return Text(
                      '$count ${loc?.translate('stores') ?? 'Stores'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.pushNamed('storeAdd');
                  },
                  icon: const Icon(Icons.add),
                  label: Text(loc?.translate('newStore') ?? 'New Store'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Stores list
          Expanded(
            child: BlocConsumer<StoreBloc, StoreState>(
              listener: (context, state) {
                if (state is StoreSwitched) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${loc?.translate('switchedTo') ?? 'Switched to'} ${state.store.name}'),
                    ),
                  );
                  context.pop(); // Go back after switching
                }
              },
              builder: (context, state) {
                if (state is StoreLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StoresLoaded) {
                  if (state.stores.isEmpty) {
                    return EmptyView(
                      message: loc?.translate('noStores') ?? 'No stores found',
                      icon: Icons.store_outlined,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.stores.length,
                    itemBuilder: (context, index) {
                      final store = state.stores[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.store,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            store.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${store.addressLine1}, ${store.city}'),
                              if (store.phone != null) Text(store.phone!),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            context.read<StoreBloc>().add(SwitchStore(store.id));
                          },
                        ),
                      );
                    },
                  );
                }

                if (state is StoreError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(loc?.translate('error') ?? 'Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<StoreBloc>().add(const LoadStores());
                          },
                          child: Text(loc?.translate('retry') ?? 'Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/permission_checker.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_router.dart' as router;
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/empty_view.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/stat_card.dart';

/// Dashboard screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Mock data - replace with BLoC when backend is ready
  final double todaySales = 1250.50;
  final int lowStockCount = 5;
  final int expiringCount = 3;
  final int totalProducts = 150;
  final int totalStaff = 8;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('dashboard') ?? AppStrings.dashboard),
        automaticallyImplyLeading: false, // No back button on dashboard
        leading: IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pushNamed('globalSearch'),
          tooltip: loc?.translate('search') ?? 'Search',
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          // Switch Store button
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () => context.pushNamed('storeSelection'),
            tooltip: loc?.translate('switchStore') ?? 'Switch Store',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.pushNamed('notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
      drawer: isTablet ? _buildDrawer() : null,
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        _buildDrawer(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildQuickActions()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildRecentActivity()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final loc = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isTablet ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 1.3 : 0.85,
          children: [
            StatCard(
              title: loc?.translate('todaySales') ?? 'Today Sales',
              value: CurrencyFormatter.format(todaySales),
              icon: Icons.point_of_sale,
              color: Colors.green,
              onTap: () => context.goNamed('salesReport'),
            ),
            StatCard(
              title: loc?.translate('lowStock') ?? 'Low Stock',
              value: lowStockCount.toString(),
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              onTap: () => context.goNamed('inventory'),
            ),
            StatCard(
              title: loc?.translate('expiringSoon') ?? 'Expiring Soon',
              value: expiringCount.toString(),
              icon: Icons.calendar_today,
              color: Colors.red,
              onTap: () => context.goNamed('inventory'),
            ),
            StatCard(
              title: loc?.translate('totalProducts') ?? 'Total Products',
              value: totalProducts.toString(),
              icon: Icons.inventory_2,
              color: Colors.blue,
              onTap: () => context.goNamed('products'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final loc = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc?.translate('quickActions') ?? 'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.point_of_sale,
                  label: loc?.translate('pos') ?? 'POS',
                  onTap: () => context.goNamed('pos'),
                ),
                _buildActionButton(
                  icon: Icons.add_shopping_cart,
                  label: loc?.translate('newPurchase') ?? 'New Purchase',
                  onTap: () => context.pushNamed('purchasesAdd'),
                ),
                _buildActionButton(
                  icon: Icons.add_box,
                  label: loc?.translate('addProduct') ?? 'Add Product',
                  onTap: () => context.pushNamed('productsAdd'),
                ),
                _buildActionButton(
                  icon: Icons.person_add,
                  label: loc?.translate('addStaff') ?? 'Add Staff',
                  onTap: () => context.pushNamed('staffAdd'),
                ),
                _buildActionButton(
                  icon: Icons.assessment,
                  label: loc?.translate('reports') ?? 'Reports',
                  onTap: () => context.goNamed('salesReport'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final loc = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc?.translate('recentActivity') ?? 'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to notifications screen (shows all activity)
                    context.pushNamed('notifications');
                  },
                  child: Text(loc?.translate('viewAll') ?? 'View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Mock recent activity with clickable items
            _buildActivityItem(
              title: 'Sale #1234',
              subtitle: '\$45.50',
              icon: Icons.receipt,
              type: 'sale',
              id: '1234',
            ),
            _buildActivityItem(
              title: 'Product Added',
              subtitle: 'Paracetamol',
              icon: Icons.add_box,
              type: 'product',
              id: '1',
            ),
            _buildActivityItem(
              title: 'Low Stock Alert',
              subtitle: 'Aspirin',
              icon: Icons.warning,
              type: 'alert',
              id: '2',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
    required String id,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        '2h ago',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        _handleActivityTap(type, id);
      },
    );
  }

  void _handleActivityTap(String type, String id) {
    switch (type) {
      case 'sale':
        // Navigate to sale detail
        context.pushNamed('saleSummary', pathParameters: {'id': id});
        break;
      case 'product':
        // Navigate to product detail
        context.pushNamed('productsEdit', pathParameters: {'id': id});
        break;
      case 'alert':
        // Navigate to inventory
        final loc = AppLocalizations.of(context);
        context.goNamed('inventory');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc?.translate('showingLowStockItems') ?? 'Showing low stock items')),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        _navigateToTab(index);
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: AppLocalizations.of(context)?.translate('dashboard') ?? 'Dashboard',
        ),
        NavigationDestination(
          icon: const Icon(Icons.point_of_sale_outlined),
          selectedIcon: const Icon(Icons.point_of_sale),
          label: AppLocalizations.of(context)?.translate('pos') ?? 'POS',
        ),
        NavigationDestination(
          icon: const Icon(Icons.inventory_2_outlined),
          selectedIcon: const Icon(Icons.inventory_2),
          label: AppLocalizations.of(context)?.translate('inventory') ?? 'Inventory',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: AppLocalizations.of(context)?.translate('profile') ?? 'Profile',
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.local_pharmacy, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              final loc = AppLocalizations.of(context);
              return Column(
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    label: loc?.translate('dashboard') ?? 'Dashboard',
                    onTap: () => context.go('/dashboard'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.point_of_sale,
                    label: loc?.translate('pos') ?? 'POS',
                    onTap: () => context.go('/pos'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.inventory_2,
                    label: loc?.translate('products') ?? 'Products',
                    onTap: () => context.go('/products'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.warehouse,
                    label: loc?.translate('inventory') ?? 'Inventory',
                    onTap: () => context.go('/inventory'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_cart,
                    label: loc?.translate('purchases') ?? 'Purchases',
                    onTap: () => context.go('/purchases'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.assessment,
                    label: loc?.translate('reports') ?? 'Reports',
                    onTap: () => context.go('/reports/sales'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    label: loc?.translate('staff') ?? 'Staff',
                    onTap: () => context.go('/staff'),
                  ),
                  // Only show Customers to Admin
                  if (AppRouter.currentUser?.role == UserRole.admin)
                    _buildDrawerItem(
                      icon: Icons.person_outline,
                      label: loc?.translate('customers') ?? 'Customers',
                      onTap: () => context.go('/customers'),
                    ),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    label: loc?.translate('notifications') ?? 'Notifications',
                    onTap: () => context.go('/notifications'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.card_membership,
                    label: loc?.translate('subscriptions') ?? 'Subscriptions',
                    onTap: () => context.go('/subscriptions'),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    label: loc?.translate('settings') ?? 'Settings',
                    onTap: () => context.go('/settings'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    label: loc?.translate('logout') ?? 'Logout',
                    onTap: () {
                      // Handle logout
                      context.go('/login');
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        context.goNamed('dashboard');
        break;
      case 1:
        context.goNamed('pos');
        break;
      case 2:
        context.goNamed('inventory');
        break;
      case 3:
        context.pushNamed('settings');
        break;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/app_enums.dart';

/// Persistent bottom navigation wrapper
class PersistentBottomNav extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const PersistentBottomNav({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<PersistentBottomNav> createState() => _PersistentBottomNavState();
}

class _PersistentBottomNavState extends State<PersistentBottomNav> {
  int _getCurrentIndex() {
    switch (widget.currentRoute) {
      case '/dashboard':
        return 0;
      case '/products':
        return 1;
      case '/pos':
        return 2;
      case '/inventory':
        return 3;
      case '/reports/sales':
      case '/reports/inventory':
        return 4;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.goNamed('dashboard');
        break;
      case 1:
        context.goNamed('products');
        break;
      case 2:
        context.goNamed('pos');
        break;
      case 3:
        context.goNamed('inventory');
        break;
      case 4:
        context.goNamed('salesReport');
        break;
    }
  }

  bool _shouldShowBottomNav() {
    // Hide bottom nav on login, register, splash, and form screens
    final hideRoutes = [
      '/login',
      '/register',
      '/splash',
      '/products/add',
      '/products/edit',
      '/staff/add',
      '/staff/edit',
      '/inventory/add',
      '/purchases/add',
      '/sales/',
    ];

    return !hideRoutes.any((route) => widget.currentRoute.startsWith(route));
  }

  @override
  Widget build(BuildContext context) {
    final user = AppRouter.currentUser;
    final canShowNav = _shouldShowBottomNav() && user != null;

    // Check if user role allows access
    if (user != null) {
      if (user.role == UserRole.cashier && widget.currentRoute != '/pos' && widget.currentRoute != '/dashboard') {
        // Cashier can only access POS and Dashboard
        return widget.child;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: canShowNav
          ? BottomNavigationBar(
              currentIndex: _getCurrentIndex(),
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Products',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.point_of_sale_outlined),
                  activeIcon: Icon(Icons.point_of_sale),
                  label: 'POS',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warehouse_outlined),
                  activeIcon: Icon(Icons.warehouse),
                  label: 'Inventory',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assessment_outlined),
                  activeIcon: Icon(Icons.assessment),
                  label: 'Reports',
                ),
              ],
            )
          : null,
    );
  }
}


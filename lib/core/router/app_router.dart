import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../../core/constants/app_enums.dart';
import '../../core/utils/permission_checker.dart';
import '../../core/di/injection_container.dart';
import '../../presentation/products/bloc/product_bloc.dart';
import '../../presentation/sales/bloc/sale_bloc.dart';
import '../../presentation/authentication/screens/login_screen.dart';
import '../../presentation/authentication/screens/register_tenant_screen.dart';
import '../../presentation/dashboard/screens/dashboard_screen.dart';
import '../../presentation/staff/screens/staff_list_screen.dart';
import '../../presentation/staff/screens/staff_form_screen.dart';
import '../../presentation/products/screens/products_screen.dart';
import '../../presentation/products/screens/product_form_screen.dart';
import '../../presentation/inventory/screens/inventory_list_screen.dart';
import '../../presentation/inventory/screens/inventory_form_screen.dart';
import '../../presentation/inventory/screens/inventory_detail_screen.dart';
import '../../presentation/sales/screens/pos_screen.dart';
import '../../presentation/sales/screens/sale_summary_screen.dart';
import '../../presentation/purchases/screens/purchase_list_screen.dart';
import '../../presentation/purchases/screens/purchase_form_screen.dart';
import '../../presentation/reports/screens/sales_report_screen.dart';
import '../../presentation/reports/screens/inventory_report_screen.dart';
import '../../presentation/reports/screens/reports_metrics_screen.dart';
import '../../presentation/reports/screens/sales_revenue_metrics_screen.dart';
import '../../presentation/reports/screens/customer_metrics_screen.dart';
import '../../presentation/reports/screens/order_metrics_screen.dart';
import '../../presentation/notifications/screens/notification_list_screen.dart';
import '../../presentation/subscriptions/screens/subscription_screen.dart';
import '../../presentation/settings/screens/settings_screen.dart';
import '../../presentation/settings/screens/profile_edit_screen.dart';
import '../../presentation/widgets/persistent_bottom_nav.dart';
import '../../presentation/categories/screens/categories_screen.dart';
import '../../presentation/categories/screens/category_form_screen.dart';
import '../../presentation/categories/bloc/category_bloc.dart';
import '../../presentation/categories/bloc/category_event.dart';
import '../../presentation/customers/screens/customers_list_screen.dart';
import '../../presentation/customers/screens/customer_form_screen.dart';
import '../../presentation/customers/screens/customer_detail_screen.dart';
import '../../presentation/customers/screens/customer_address_book_screen.dart';
import '../../presentation/stores/screens/store_selection_screen.dart';
import '../../presentation/stores/screens/store_form_screen.dart';
import '../../presentation/stores/bloc/store_bloc.dart';
import '../../presentation/customers/bloc/customer_bloc.dart';
import '../../presentation/wallet/screens/customer_wallet_screen.dart';
import '../../presentation/wallet/screens/wallet_transactions_screen.dart';
import '../../presentation/wallet/screens/top_up_screen.dart';
import '../../presentation/wallet/bloc/wallet_bloc.dart';
import '../../presentation/payment_methods/screens/payment_methods_list_screen.dart';
import '../../presentation/payment_methods/screens/payment_method_form_screen.dart';
import '../../presentation/payment_methods/bloc/payment_method_bloc.dart';
import '../../presentation/search/screens/global_search_screen.dart';
import '../../presentation/search/bloc/search_bloc.dart';
import '../../presentation/sales/screens/sales_history_screen.dart';

/// Named route constants for type-safe navigation
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String staff = '/staff';
  static const String staffAdd = '/staff/add';
  static const String staffEdit = '/staff/edit';
  static const String products = '/products';
  static const String productsAdd = '/products/add';
  static const String productsEdit = '/products/edit';
  static const String inventory = '/inventory';
  static const String inventoryAdd = '/inventory/add';
  static const String inventoryEdit = '/inventory/edit';
  static const String inventoryDetail = '/inventory/detail';
  static const String pos = '/pos';
  static const String saleSummary = '/sales';
  static const String purchases = '/purchases';
  static const String purchasesAdd = '/purchases/add';
  static const String purchasesEdit = '/purchases/edit';
  static const String salesReport = '/reports/sales';
  static const String inventoryReport = '/reports/inventory';
  static const String notifications = '/notifications';
  static const String subscriptions = '/subscriptions';
  static const String settings = '/settings';
  static const String profileEdit = '/settings/profile/edit';
  static const String categories = '/categories';
  static const String categoryAdd = '/categories/add';
  static const String categoryEdit = '/categories/edit';
  static const String customers = '/customers';
  static const String customerAdd = '/customers/add';
  static const String customerEdit = '/customers/edit';
  static const String customerDetail = '/customers/detail';
  static const String customerAddressBook = '/customers/address';
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTopUp = '/wallet/topup';
  static const String paymentMethods = '/payment-methods';
  static const String paymentMethodAdd = '/payment-methods/add';
  static const String paymentMethodEdit = '/payment-methods/edit';
  static const String globalSearch = '/search';
  static const String salesHistory = '/sales/history';
  // Store/Branch Management
  static const String storeSelection = '/stores/selection';
  static const String storeAdd = '/stores/add';
  static const String storeEdit = '/stores/edit/:storeId';
  // Store Timings
  static const String storeTimings = '/stores/timings';
  static const String storeTimingAdd = '/stores/timings/add';
  static const String storeTimingEdit = '/stores/timings/edit/:timingId';
  // Delivery Rates
  static const String deliveryRates = '/stores/delivery-rates';
  static const String deliveryRateAdd = '/stores/delivery-rates/add';
  static const String deliveryRateEdit = '/stores/delivery-rates/edit/:rateId';
  // Add-ons
  static const String addOns = '/addons';
  static const String addOnAdd = '/addons/add';
  static const String addOnEdit = '/addons/edit/:addonId';
  // Ingredients
  static const String ingredients = '/ingredients';
  static const String ingredientAdd = '/ingredients/add';
  static const String ingredientEdit = '/ingredients/edit/:ingredientId';
  // Enhanced Reports
  static const String reportsMetrics = '/reports/metrics';
  static const String salesRevenueMetrics = '/reports/sales-revenue';
  static const String customerMetrics = '/reports/customer';
  static const String orderMetrics = '/reports/order';
}

/// App router configuration
class AppRouter {
  static User? currentUser;

  /// Set current user (for testing without backend)
  static void setMockUser(User user) {
    currentUser = user;
  }

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterTenantScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => PersistentBottomNav(
          currentRoute: AppRoutes.dashboard,
          child: const DashboardScreen(),
        ),
      ),
      // Staff routes
      GoRoute(
        path: AppRoutes.staff,
        name: 'staff',
        builder: (context, state) => const StaffListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'staffAdd',
            builder: (context, state) => const StaffFormScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'staffEdit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return StaffFormScreen(staffId: id);
            },
          ),
        ],
      ),
      // Product routes
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => getIt<ProductBloc>(),
            child: PersistentBottomNav(
              currentRoute: AppRoutes.products,
              child: const ProductsScreen(),
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'add',
            name: 'productsAdd',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<ProductBloc>()),
                BlocProvider(create: (_) => CategoryBloc()..add(const LoadCategories())),
              ],
              child: const ProductFormScreen(),
            ),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'productsEdit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => getIt<ProductBloc>()),
                  BlocProvider(create: (_) => CategoryBloc()..add(const LoadCategories())),
                ],
                child: ProductFormScreen(productId: id),
              );
            },
          ),
        ],
      ),
      // Inventory routes
      GoRoute(
        path: AppRoutes.inventory,
        name: 'inventory',
        builder: (context, state) => PersistentBottomNav(
          currentRoute: AppRoutes.inventory,
          child: const InventoryListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'add',
            name: 'inventoryAdd',
            builder: (context, state) => const InventoryFormScreen(),
          ),
          GoRoute(
            path: 'detail/:batchId',
            name: 'inventoryDetail',
            builder: (context, state) {
              final batchId = state.pathParameters['batchId']!;
              return InventoryDetailScreen(batchId: batchId);
            },
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'inventoryEdit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InventoryFormScreen(batchId: id);
            },
          ),
        ],
      ),
      // Sales routes
      GoRoute(
        path: AppRoutes.pos,
        name: 'pos',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<SaleBloc>()),
              BlocProvider(create: (_) => getIt<ProductBloc>()),
              BlocProvider(create: (_) => CategoryBloc()..add(const LoadCategories())),
            ],
            child: PersistentBottomNav(
              currentRoute: AppRoutes.pos,
              child: const PosScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.saleSummary}/:id',
        name: 'saleSummary',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SaleSummaryScreen(saleId: id);
        },
      ),
      // Purchase routes
      GoRoute(
        path: AppRoutes.purchases,
        name: 'purchases',
        builder: (context, state) => const PurchaseListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'purchasesAdd',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<ProductBloc>(),
              child: const PurchaseFormScreen(),
            ),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'purchasesEdit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => getIt<ProductBloc>(),
                child: PurchaseFormScreen(purchaseId: id),
              );
            },
          ),
        ],
      ),
      // Reports routes
      GoRoute(
        path: AppRoutes.salesReport,
        name: 'salesReport',
        builder: (context, state) => PersistentBottomNav(
          currentRoute: AppRoutes.salesReport,
          child: const SalesReportScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.inventoryReport,
        name: 'inventoryReport',
        builder: (context, state) => PersistentBottomNav(
          currentRoute: AppRoutes.inventoryReport,
          child: const InventoryReportScreen(),
        ),
      ),
      // Notifications
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationListScreen(),
      ),
      // Subscriptions
      GoRoute(
        path: AppRoutes.subscriptions,
        name: 'subscriptions',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      // Settings routes
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'profile/edit',
            name: 'profileEdit',
            builder: (context, state) => const ProfileEditScreen(),
          ),
        ],
      ),
      // Categories routes
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        builder: (context, state) => BlocProvider(
          create: (_) => CategoryBloc(),
          child: const CategoriesScreen(),
        ),
        routes: [
          GoRoute(
            path: 'add',
            name: 'categoryAdd',
            builder: (context, state) => BlocProvider(
              create: (_) => CategoryBloc()..add(const LoadCategories()),
              child: const CategoryFormScreen(),
            ),
          ),
          GoRoute(
            path: 'edit/:categoryId',
            name: 'categoryEdit',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId']!;
              return BlocProvider(
                create: (_) => CategoryBloc()..add(const LoadCategories()),
                child: CategoryFormScreen(categoryId: categoryId),
              );
            },
          ),
        ],
      ),
      // Customers routes - Address Book
      GoRoute(
        path: '/customers/address',
        name: 'customerAddressBook',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CustomerAddressBookScreen(
            customerId: extra?['customerId'] ?? '',
            customerName: extra?['customerName'] ?? '',
          );
        },
      ),
      // Wallet routes
      GoRoute(
        path: AppRoutes.wallet,
        name: 'wallet',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (_) => WalletBloc(),
            child: CustomerWalletScreen(
              customerId: extra?['customerId'] ?? '',
              customerName: extra?['customerName'] ?? '',
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'transactions',
            name: 'walletTransactions',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BlocProvider(
                create: (_) => WalletBloc(),
                child: WalletTransactionsScreen(
                  customerId: extra?['customerId'] ?? '',
                  customerName: extra?['customerName'] ?? '',
                ),
              );
            },
          ),
          GoRoute(
            path: 'topup',
            name: 'walletTopUp',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BlocProvider(
                create: (_) => WalletBloc(),
                child: TopUpScreen(
                  customerId: extra?['customerId'] ?? '',
                  customerName: extra?['customerName'] ?? '',
                ),
              );
            },
          ),
        ],
      ),
      // Payment Methods routes
      GoRoute(
        path: AppRoutes.paymentMethods,
        name: 'paymentMethods',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (_) => PaymentMethodBloc(),
            child: PaymentMethodsListScreen(customerId: extra?['customerId']),
          );
        },
        routes: [
          GoRoute(
            path: 'add',
            name: 'paymentMethodAdd',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BlocProvider(
                create: (_) => PaymentMethodBloc(),
                child: PaymentMethodFormScreen(customerId: extra?['customerId']),
              );
            },
          ),
          GoRoute(
            path: 'edit',
            name: 'paymentMethodEdit',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BlocProvider(
                create: (_) => PaymentMethodBloc(),
                child: PaymentMethodFormScreen(
                  method: extra?['method'],
                  customerId: extra?['customerId'],
                ),
              );
            },
          ),
        ],
      ),
      // Global Search
      GoRoute(
        path: AppRoutes.globalSearch,
        name: 'globalSearch',
        builder: (context, state) => BlocProvider(
          create: (_) => SearchBloc(),
          child: const GlobalSearchScreen(),
        ),
      ),
      // Sales History
      GoRoute(
        path: AppRoutes.salesHistory,
        name: 'salesHistory',
        builder: (context, state) => const SalesHistoryScreen(),
      ),
      // Store Selection
      GoRoute(
        path: AppRoutes.storeSelection,
        name: 'storeSelection',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<StoreBloc>(),
          child: const StoreSelectionScreen(),
        ),
        routes: [
          GoRoute(
            path: 'add',
            name: 'storeAdd',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<StoreBloc>(),
              child: const StoreFormScreen(),
            ),
          ),
          GoRoute(
            path: 'edit/:storeId',
            name: 'storeEdit',
            builder: (context, state) {
              final storeId = state.pathParameters['storeId']!;
              return BlocProvider(
                create: (_) => getIt<StoreBloc>(),
                child: StoreFormScreen(storeId: storeId),
              );
            },
          ),
        ],
      ),
      // Reports Metrics
      GoRoute(
        path: AppRoutes.reportsMetrics,
        name: 'reportsMetrics',
        builder: (context, state) => const ReportsMetricsScreen(),
      ),
      GoRoute(
        path: AppRoutes.salesRevenueMetrics,
        name: 'salesRevenueMetrics',
        builder: (context, state) => const SalesRevenueMetricsScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerMetrics,
        name: 'customerMetrics',
        builder: (context, state) => const CustomerMetricsScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderMetrics,
        name: 'orderMetrics',
        builder: (context, state) => const OrderMetricsScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = currentUser != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.register || state.matchedLocation == AppRoutes.splash;

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login;
      }

      // Redirect to dashboard if logged in and on login/register
      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.dashboard;
      }

      // Role-based access control
      if (isLoggedIn && currentUser != null) {
        final user = currentUser!;
        final location = state.matchedLocation;

        // Cashier can only access POS
        if (user.role == UserRole.cashier &&
            location != AppRoutes.pos &&
            location != AppRoutes.dashboard &&
            location != AppRoutes.settings &&
            !location.startsWith(AppRoutes.settings)) {
          return AppRoutes.pos;
        }

        // Manager cannot access subscriptions
        if (user.role == UserRole.manager && location == AppRoutes.subscriptions) {
          return AppRoutes.dashboard;
        }
      }

      return null;
    },
  );
}

/// Splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      if (AppRouter.currentUser != null) {
        context.go(AppRoutes.dashboard);
      } else {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_pharmacy,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Pharmacy POS',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/product.dart';
import '../../products/bloc/product_bloc.dart';
import '../../products/bloc/product_event.dart';
import '../../products/bloc/product_state.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/bloc/category_event.dart';
import '../../categories/bloc/category_state.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../../../core/constants/app_enums.dart';
import '../widgets/universal_search_bar.dart';
import '../widgets/product_card_enhanced.dart';

/// Point of Sale screen - Enhanced for large store operations
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchController = TextEditingController();
  final _discountController = TextEditingController();
  final _barcodeController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  bool _isScanning = false;
  final MobileScannerController _scannerController = MobileScannerController();

  // Mock customers - will be localized in UI
  final List<Map<String, dynamic>> _mockCustomers = [
    {'id': 'walkin', 'nameKey': 'walkInCustomer', 'phone': null},
    {'id': 'cust1', 'name': 'John Doe', 'phone': '+1234567890'},
    {'id': 'cust2', 'name': 'Jane Smith', 'phone': '+0987654321'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = 'walkin';
    // Will be localized when displayed
    // Load products and categories
    context.read<ProductBloc>().add(const LoadProducts());
    context.read<CategoryBloc>().add(const LoadCategories());
    
    // Focus search field for quick typing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _barcodeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    // Handle customer search (starts with /)
    if (query.startsWith('/')) {
      // Customer search handled by universal search bar
      return;
    }
    
    // Product search - search by name, barcode, SKU, or ID
    context.read<ProductBloc>().add(
          LoadProducts(
            search: query.isEmpty ? null : query,
            category: _selectedCategoryId,
          ),
        );
  }
  
  void _handleProductSelected(String productId) {
    // Find product and add to cart directly
    final productState = context.read<ProductBloc>().state;
    if (productState is ProductsLoaded) {
      final product = productState.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => productState.products.first,
      );
      // Quick add with quantity 1
      context.read<SaleBloc>().add(
            AddItemToCart(
              productId: product.id,
              productName: product.name,
              price: product.price,
              quantity: 1,
            ),
          );
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ${loc?.translate('addedToCart') ?? 'added to cart'}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
  
  void _handleCustomerSelected(String customerId) {
    final loc = AppLocalizations.of(context);
    final customer = _mockCustomers.firstWhere(
      (c) => c['id'] == customerId,
      orElse: () => _mockCustomers[0],
    );
    setState(() {
      _selectedCustomerId = customer['id'];
      if (customer['nameKey'] != null) {
        _selectedCustomerName = loc?.translate(customer['nameKey']) ?? 'Walk-in Customer';
      } else {
        _selectedCustomerName = customer['name'];
      }
    });
    _searchController.clear();
  }

  void _handleBarcodeScan(String barcode) {
    final loc = AppLocalizations.of(context);
    // Search product by barcode
    context.read<ProductBloc>().add(LoadProducts(search: barcode));
    
    // Wait for products to load, then add first matching product to cart
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final productState = context.read<ProductBloc>().state;
      if (productState is ProductsLoaded && productState.products.isNotEmpty) {
        // Find product matching the barcode exactly
        Product? matchingProduct;
        try {
          matchingProduct = productState.products.firstWhere(
            (p) => p.barcode == barcode || p.sku == barcode || p.id == barcode,
          );
        } catch (e) {
          // If exact match not found, use first product from search results
          matchingProduct = productState.products.first;
        }
        
        if (matchingProduct != null) {
          // Auto-add to cart with quantity 1
          context.read<SaleBloc>().add(
                AddItemToCart(
                  productId: matchingProduct.id,
                  productName: matchingProduct.name,
                  price: matchingProduct.price,
                  quantity: 1,
                ),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${matchingProduct.name} ${loc?.translate('addedToCart') ?? 'added to cart'}'),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc?.translate('productNotFound') ?? 'Product not found'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc?.translate('productNotFound') ?? 'Product not found'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _showQuantityDialog(BuildContext context, String productId, String productName, double price) {
    final quantityController = TextEditingController(text: '1');
    final loc = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${loc?.translate('price') ?? 'Price'}: ${CurrencyFormatter.format(price)}',
              style: Theme.of(context).textTheme.titleMedium,
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
            // Quick quantity buttons
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
                context.read<SaleBloc>().add(
                      AddItemToCart(
                        productId: productId,
                        productName: productName,
                        price: price,
                        quantity: quantity,
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$productName x$quantity ${loc?.translate('added') ?? 'added to cart'}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Text(loc?.translate('add') ?? 'Add'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc?.translate('selectCustomer') ?? 'Select Customer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _mockCustomers.length,
            itemBuilder: (context, index) {
              final customer = _mockCustomers[index];
              final customerName = customer['nameKey'] != null
                  ? (loc?.translate(customer['nameKey']) ?? 'Walk-in Customer')
                  : customer['name'];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(customerName),
                subtitle: customer['phone'] != null ? Text(customer['phone']) : null,
                selected: _selectedCustomerId == customer['id'],
                onTap: () {
                  setState(() {
                    _selectedCustomerId = customer['id'];
                    if (customer['nameKey'] != null) {
                      _selectedCustomerName = loc?.translate(customer['nameKey']) ?? 'Walk-in Customer';
                    } else {
                      _selectedCustomerName = customer['name'];
                    }
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add customer screen
              context.pushNamed('customerAdd');
            },
            child: Text(loc?.translate('addCustomer') ?? 'Add Customer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('pos') ?? 'POS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('dashboard'),
        ),
        actions: [
          // Barcode scanner button
          IconButton(
            icon: Icon(_isScanning ? Icons.qr_code_scanner : Icons.qr_code_scanner_outlined),
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });
            },
            tooltip: loc?.translate('scanBarcode') ?? 'Scan Barcode',
          ),
          // Customer selection
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showCustomerDialog(context),
            tooltip: loc?.translate('selectCustomer') ?? 'Select Customer',
          ),
        ],
      ),
      body: BlocConsumer<SaleBloc, SaleState>(
        listener: (context, saleState) {
          if (saleState is SaleSuccess) {
            // Navigate to sale summary
            context.goNamed('saleSummary', pathParameters: {'id': saleState.sale.id});
          } else if (saleState is SaleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(saleState.message)),
            );
          }
        },
        builder: (context, saleState) {
          if (saleState is SaleProcessing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (saleState is SaleCartState) {
            final isTablet = MediaQuery.of(context).size.width >= 900;
            
            if (isTablet) {
              return _buildTabletLayout(context, saleState, loc);
            } else {
              return _buildMobileLayout(context, saleState, loc);
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, SaleCartState saleState, AppLocalizations? loc) {
    return Row(
      children: [
        // Products/Items area
        Expanded(
          flex: 2,
          child: Column(
            children: [
                          // Customer info bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: Row(
                              children: [
                                const Icon(Icons.person, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedCustomerName ?? loc?.translate('walkInCustomer') ?? 'Walk-in Customer',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showCustomerDialog(context),
                                  child: Text(loc?.translate('change') ?? 'Change'),
                                ),
                              ],
                            ),
                          ),
                          
                          // Search/Product selection area
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Barcode scanner view
                                if (_isScanning)
                                  Container(
                                    height: 200,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.green, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: MobileScanner(
                                        controller: _scannerController,
                                        onDetect: (capture) {
                                          final List<Barcode> barcodes = capture.barcodes;
                                          for (final barcode in barcodes) {
                                            if (barcode.rawValue != null) {
                                              _handleBarcodeScan(barcode.rawValue!);
                                              break;
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                
                                // Universal search bar
                                UniversalSearchBar(
                                  controller: _searchController,
                                  onSearch: _handleSearch,
                                  onProductSelected: _handleProductSelected,
                                  onCustomerSelected: _handleCustomerSelected,
                                  showAdvancedFilters: true,
                                ),
                                const SizedBox(height: 12),
                                
                                // Category filter
                                BlocBuilder<CategoryBloc, CategoryState>(
                                  builder: (context, categoryState) {
                                    List<dynamic> categories = [];
                                    if (categoryState is CategoriesLoaded) {
                                      categories = categoryState.categories;
                                    }

                                    return DropdownButtonFormField<String>(
                                      value: _selectedCategoryId,
                                      decoration: InputDecoration(
                                        labelText: loc?.translate('filterByCategory') ?? 'Filter by Category',
                                        prefixIcon: const Icon(Icons.category),
                                        border: const OutlineInputBorder(),
                                      ),
                                      hint: Text(loc?.translate('allCategories') ?? 'All Categories'),
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: null,
                                          child: Text(loc?.translate('allCategories') ?? 'All Categories'),
                                        ),
                                        ...categories.map((category) {
                                          return DropdownMenuItem<String>(
                                            value: category['id'],
                                            child: Text(category['name']),
                                          );
                                        }),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCategoryId = value;
                                        });
                                        context.read<ProductBloc>().add(
                                              LoadProducts(
                                                search: _searchController.text.isEmpty
                                                    ? null
                                                    : _searchController.text,
                                                category: value,
                                              ),
                                            );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          // Product grid/list
                          Expanded(
                            child: BlocBuilder<ProductBloc, ProductState>(
                              builder: (context, productState) {
                                if (productState is ProductLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (productState is ProductError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(productState.message),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.read<ProductBloc>().add(const LoadProducts());
                                          },
                                          child: Text(loc?.translate('retry') ?? 'Retry'),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (productState is ProductsLoaded) {
                                  if (productState.products.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 64,
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            loc?.translate('noProducts') ?? 'No products found',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 3,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemCount: productState.products.length,
                                    itemBuilder: (context, index) {
                                      final product = productState.products[index];
                                      // Mock stock data - in production, get from inventory
                                      final stockOnHand = (index % 3 == 0) ? 0 : (index % 5 == 0 ? 5 : 50);
                                      final productType = index % 4 == 0 ? 'RX' : 'OTC';
                                      final isScriptWaiting = index % 7 == 0;
                                      
                                      // Mock variants for some products
                                      List<Product>? variants;
                                      if (index % 3 == 0) {
                                        variants = [
                                          product.copyWith(name: '${product.name} - 100mg', price: product.price),
                                          product.copyWith(name: '${product.name} - 200mg', price: product.price * 1.5),
                                          product.copyWith(name: '${product.name} - 500mg', price: product.price * 2),
                                        ];
                                      }
                                      
                                      return ProductCardEnhanced(
                                        product: product,
                                        stockOnHand: stockOnHand,
                                        productType: productType,
                                        variants: variants,
                                        isScriptWaiting: isScriptWaiting,
                                        onAddToCart: (prod, qty) {
                                          context.read<SaleBloc>().add(
                                                AddItemToCart(
                                                  productId: prod.id,
                                                  productName: prod.name,
                                                  price: prod.price,
                                                  quantity: qty,
                                                ),
                                              );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${prod.name} x$qty ${loc?.translate('added') ?? 'added'}'),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }

                                return Center(
                      child: Text(loc?.translate('noProductsAvailable') ?? 'No products available'),
                    );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

        // Cart/Checkout area
        Container(
          width: 450,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(-2, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Cart header
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${loc?.translate('cart') ?? 'Cart'} (${saleState.items.length})',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // Cart items
                          Expanded(
                            child: saleState.items.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.outline,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          loc?.translate('cartEmpty') ?? 'Cart is empty',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          loc?.translate('addProductsToCart') ?? 'Add products to cart',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: saleState.items.length,
                                    itemBuilder: (context, index) {
                                      final item = saleState.items[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 4,
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          title: Text(
                                            item.productName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}',
                                              ),
                                              const SizedBox(height: 8),
                                              // Quantity controls
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () {
                                                      if (item.quantity > 1) {
                                                        context.read<SaleBloc>().add(
                                                              UpdateItemQuantity(
                                                                itemId: item.id,
                                                                quantity: item.quantity - 1,
                                                              ),
                                                            );
                                                      } else {
                                                        context.read<SaleBloc>().add(
                                                              RemoveItemFromCart(item.id),
                                                            );
                                                      }
                                                    },
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () {
                                                      context.read<SaleBloc>().add(
                                                            UpdateItemQuantity(
                                                              itemId: item.id,
                                                              quantity: item.quantity + 1,
                                                            ),
                                                          );
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Quick quantity buttons
                                                  ...([5, 10].map((qty) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(left: 4),
                                                      child: InkWell(
                                                        onTap: () {
                                                          context.read<SaleBloc>().add(
                                                                UpdateItemQuantity(
                                                                  itemId: item.id,
                                                                  quantity: qty,
                                                                ),
                                                              );
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.grey),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            '$qty',
                                                            style: const TextStyle(fontSize: 12),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  })),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                CurrencyFormatter.format(item.total),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 20),
                                                color: Colors.red,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () {
                                                  context.read<SaleBloc>().add(
                                                        RemoveItemFromCart(item.id),
                                                      );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          // Discount input
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                            child: TextField(
                              controller: _discountController,
                              decoration: InputDecoration(
                                labelText: loc?.translate('discount') ?? 'Discount',
                                prefixIcon: const Icon(Icons.discount),
                                hintText: '0.00',
                                suffixText: loc?.translate('amount') ?? 'Amount',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final discount = double.tryParse(value) ?? 0.0;
                                context.read<SaleBloc>().add(ApplyDiscount(discount));
                              },
                            ),
                          ),

                          // Totals
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                            child: Column(
                              children: [
                                _buildTotalRow(
                                  context,
                                  loc?.translate('subtotal') ?? 'Subtotal',
                                  CurrencyFormatter.format(saleState.subtotal),
                                ),
                                if (saleState.discount > 0)
                                  _buildTotalRow(
                                    context,
                                    loc?.translate('discount') ?? 'Discount',
                                    '-${CurrencyFormatter.format(saleState.discount)}',
                                  ),
                                _buildTotalRow(
                                  context,
                                  loc?.translate('tax') ?? 'Tax',
                                  CurrencyFormatter.format(saleState.tax),
                                ),
                                const Divider(),
                                _buildTotalRow(
                                  context,
                                  loc?.translate('total') ?? 'Total',
                                  CurrencyFormatter.format(saleState.total),
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),

                          // Payment method and checkout
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                            ),
                            child: Column(
                              children: [
                                DropdownButtonFormField<PaymentMethod>(
                                  value: saleState.paymentMethod,
                                  decoration: InputDecoration(
                                    labelText: loc?.translate('paymentMethod') ?? 'Payment Method',
                                    prefixIcon: const Icon(Icons.payment),
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                  ),
                                  items: PaymentMethod.values.map((method) {
                                    return DropdownMenuItem(
                                      value: method,
                                      child: Text(method.name.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (method) {
                                    if (method != null) {
                                      context.read<SaleBloc>().add(SetPaymentMethod(method));
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: saleState.items.isEmpty
                                        ? null
                                        : () {
                                            // Show confirmation
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(loc?.translate('confirmSale') ?? 'Confirm Sale'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('${loc?.translate('customer') ?? 'Customer'}: $_selectedCustomerName'),
                                                    const SizedBox(height: 8),
                                                    Text('${loc?.translate('items') ?? 'Items'}: ${saleState.items.length}'),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      '${loc?.translate('total') ?? 'Total'}: ${CurrencyFormatter.format(saleState.total)}',
                                                      style: Theme.of(context).textTheme.titleLarge,
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
                                                      Navigator.pop(context);
                                                      context.read<SaleBloc>().add(
                                                            const ProcessSale(),
                                                          );
                                                    },
                                                    child: Text(loc?.translate('processSale') ?? 'Process Sale'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: Text(
                                      loc?.translate('processSale') ?? 'Process Sale',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, SaleCartState saleState, AppLocalizations? loc) {
    return Column(
      children: [
        // Customer info bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedCustomerName ?? loc?.translate('walkInCustomer') ?? 'Walk-in Customer',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () => _showCustomerDialog(context),
                child: Text(loc?.translate('change') ?? 'Change'),
              ),
            ],
          ),
        ),
        
        // Products area (scrollable)
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search/Product selection area
              Flexible(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isScanning)
                        Container(
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: MobileScanner(
                              controller: _scannerController,
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  if (barcode.rawValue != null) {
                                    _handleBarcodeScan(barcode.rawValue!);
                                    break;
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      UniversalSearchBar(
                        controller: _searchController,
                        onSearch: _handleSearch,
                        onProductSelected: _handleProductSelected,
                        onCustomerSelected: _handleCustomerSelected,
                        showAdvancedFilters: true,
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, categoryState) {
                          List<dynamic> categories = [];
                          if (categoryState is CategoriesLoaded) {
                            categories = categoryState.categories;
                          }
                          return DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: InputDecoration(
                              labelText: loc?.translate('filterByCategory') ?? 'Filter by Category',
                              prefixIcon: const Icon(Icons.category),
                              border: const OutlineInputBorder(),
                            ),
                            hint: Text(loc?.translate('allCategories') ?? 'All Categories'),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(loc?.translate('allCategories') ?? 'All Categories'),
                              ),
                              ...categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category['id'],
                                  child: Text(category['name']),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                              context.read<ProductBloc>().add(
                                    LoadProducts(
                                      search: _searchController.text.isEmpty
                                          ? null
                                          : _searchController.text,
                                      category: value,
                                    ),
                                  );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Product grid
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, productState) {
                    if (productState is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (productState is ProductError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(productState.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ProductBloc>().add(const LoadProducts());
                              },
                              child: Text(loc?.translate('retry') ?? 'Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (productState is ProductsLoaded) {
                      if (productState.products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                loc?.translate('noProducts') ?? 'No products found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: productState.products.length,
                        itemBuilder: (context, index) {
                          final product = productState.products[index];
                          // Mock stock data
                          final stockOnHand = (index % 3 == 0) ? 0 : (index % 5 == 0 ? 5 : 50);
                          final productType = index % 4 == 0 ? 'RX' : 'OTC';
                          final isScriptWaiting = index % 7 == 0;
                          
                          return ProductCardEnhanced(
                            product: product,
                            stockOnHand: stockOnHand,
                            productType: productType,
                            isScriptWaiting: isScriptWaiting,
                            onAddToCart: (prod, qty) {
                              context.read<SaleBloc>().add(
                                    AddItemToCart(
                                      productId: prod.id,
                                      productName: prod.name,
                                      price: prod.price,
                                      quantity: qty,
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${prod.name} x$qty ${loc?.translate('added') ?? 'added'}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return Center(
                      child: Text(loc?.translate('noProductsAvailable') ?? 'No products available'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Cart area (bottom sheet style)
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Cart header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${loc?.translate('cart') ?? 'Cart'} (${saleState.items.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Cart items
              Expanded(
                child: saleState.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc?.translate('cartEmpty') ?? 'Cart is empty',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: saleState.items.length,
                        itemBuilder: (context, index) {
                          final item = saleState.items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: ListTile(
                              dense: true,
                              title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(item.total),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    color: Colors.red,
                                    onPressed: () {
                                      context.read<SaleBloc>().add(RemoveItemFromCart(item.id));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Totals and checkout
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Column(
                  children: [
                    _buildTotalRow(
                      context,
                      loc?.translate('total') ?? 'Total',
                      CurrencyFormatter.format(saleState.total),
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: saleState.items.isEmpty
                            ? null
                            : () {
                                context.read<SaleBloc>().add(const ProcessSale());
                              },
                        child: Text(
                          loc?.translate('processSale') ?? 'Process Sale',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/entities/customer.dart';

part 'search_event.dart';
part 'search_state.dart';

/// Global search BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<PerformSearch>(_onPerformSearch);
    on<ClearSearch>(_onClearSearch);
  }

  // Mock data
  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Paracetamol 500mg',
      description: 'Pain reliever',
      barcode: '1234567890',
      sku: 'SKU001',
      price: 10.0,
      category: 'cat1',
      tenantId: 'tenant1',
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  final List<Sale> _mockSales = [];
  final List<Customer> _mockCustomers = [];

  void _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    
    final query = event.query.toLowerCase();
    final results = SearchResults(
      products: _mockProducts
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.barcode?.toLowerCase().contains(query) == true ||
              p.sku?.toLowerCase().contains(query) == true)
          .toList(),
      sales: _mockSales
          .where((s) =>
              s.invoiceNumber.toLowerCase().contains(query) ||
              s.customerName?.toLowerCase().contains(query) == true)
          .toList(),
      customers: _mockCustomers
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.email?.toLowerCase().contains(query) == true ||
              c.phone?.toLowerCase().contains(query) == true)
          .toList(),
    );
    
    emit(SearchLoaded(results: results));
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}

/// Search results model
class SearchResults {
  final List<Product> products;
  final List<Sale> sales;
  final List<Customer> customers;

  SearchResults({
    required this.products,
    required this.sales,
    required this.customers,
  });

  bool get isEmpty => products.isEmpty && sales.isEmpty && customers.isEmpty;
}


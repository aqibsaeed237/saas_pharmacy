import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

/// Product states
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Loading state
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Products loaded state
class ProductsLoaded extends ProductState {
  final List<Product> products;
  final bool hasMore;
  final int currentPage;

  const ProductsLoaded({
    required this.products,
    this.hasMore = true,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [products, hasMore, currentPage];
}

/// Product loaded state
class ProductLoaded extends ProductState {
  final Product product;

  const ProductLoaded(this.product);

  @override
  List<Object> get props => [product];
}

/// Error state
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

/// Product operation success state
class ProductOperationSuccess extends ProductState {
  final String message;

  const ProductOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}


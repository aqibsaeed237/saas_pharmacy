import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

/// Product events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load products event
class LoadProducts extends ProductEvent {
  final int page;
  final String? search;
  final String? category;

  const LoadProducts({
    this.page = 1,
    this.search,
    this.category,
  });

  @override
  List<Object?> get props => [page, search, category];
}

/// Load product by ID event
class LoadProductById extends ProductEvent {
  final String id;

  const LoadProductById(this.id);

  @override
  List<Object> get props => [id];
}

/// Create product event
class CreateProduct extends ProductEvent {
  final Product product;

  const CreateProduct(this.product);

  @override
  List<Object> get props => [product];
}

/// Update product event
class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object> get props => [product];
}

/// Delete product event
class DeleteProduct extends ProductEvent {
  final String id;

  const DeleteProduct(this.id);

  @override
  List<Object> get props => [id];
}


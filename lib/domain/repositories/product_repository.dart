import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/product.dart';

/// Product repository interface
abstract class ProductRepository {
  /// Get all products with pagination
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? category,
  });

  /// Get product by ID
  Future<Either<Failure, Product>> getProductById(String id);

  /// Get product by barcode
  Future<Either<Failure, Product>> getProductByBarcode(String barcode);

  /// Create new product
  Future<Either<Failure, Product>> createProduct(Product product);

  /// Update product
  Future<Either<Failure, Product>> updateProduct(Product product);

  /// Delete product
  Future<Either<Failure, void>> deleteProduct(String id);
}


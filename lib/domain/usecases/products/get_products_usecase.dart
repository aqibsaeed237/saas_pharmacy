import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

/// Use case to get products with pagination
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? category,
  }) async {
    return await repository.getProducts(
      page: page,
      pageSize: pageSize,
      search: search,
      category: category,
    );
  }
}


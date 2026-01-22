import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

/// Use case to create a new product
class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(Product product) async {
    return await repository.createProduct(product);
  }
}


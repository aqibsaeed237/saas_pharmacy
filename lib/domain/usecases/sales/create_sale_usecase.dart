import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/sale.dart';
import '../../repositories/sale_repository.dart';

/// Use case to create a new sale
class CreateSaleUseCase {
  final SaleRepository repository;

  CreateSaleUseCase(this.repository);

  Future<Either<Failure, Sale>> call(Sale sale) async {
    return await repository.createSale(sale);
  }
}


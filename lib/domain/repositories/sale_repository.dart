import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/sale.dart';

/// Sale repository interface
abstract class SaleRepository {
  /// Get all sales with pagination
  Future<Either<Failure, List<Sale>>> getSales({
    int page = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
  });

  /// Get sale by ID
  Future<Either<Failure, Sale>> getSaleById(String id);

  /// Create new sale
  Future<Either<Failure, Sale>> createSale(Sale sale);

  /// Generate invoice number
  Future<Either<Failure, String>> generateInvoiceNumber();
}


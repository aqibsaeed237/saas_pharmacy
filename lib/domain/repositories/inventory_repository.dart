import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/inventory_batch.dart';

/// Inventory repository interface
abstract class InventoryRepository {
  /// Get inventory batches for a product
  Future<Either<Failure, List<InventoryBatch>>> getBatchesByProduct(
    String productId,
  );

  /// Get all inventory batches with filters
  Future<Either<Failure, List<InventoryBatch>>> getBatches({
    int page = 1,
    int pageSize = 20,
    String? productId,
    bool? expired,
    bool? expiringSoon,
  });

  /// Add inventory batch
  Future<Either<Failure, InventoryBatch>> addBatch(InventoryBatch batch);

  /// Update inventory batch
  Future<Either<Failure, InventoryBatch>> updateBatch(InventoryBatch batch);

  /// Deduct inventory (FIFO)
  Future<Either<Failure, void>> deductInventory(
    String productId,
    int quantity,
  );

  /// Get low stock products
  Future<Either<Failure, List<InventoryBatch>>> getLowStock({
    int threshold = 10,
  });

  /// Get expiring products
  Future<Either<Failure, List<InventoryBatch>>> getExpiringProducts({
    int days = 30,
  });
}


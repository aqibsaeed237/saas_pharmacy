import 'package:equatable/equatable.dart';

/// Inventory batch entity (FIFO tracking)
class InventoryBatch extends Equatable {
  final String id;
  final String productId;
  final int quantity;
  final int remainingQuantity;
  final double costPrice;
  final DateTime expiryDate;
  final String? batchNumber;
  final String tenantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const InventoryBatch({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.remainingQuantity,
    required this.costPrice,
    required this.expiryDate,
    this.batchNumber,
    required this.tenantId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isExpiringSoon {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  InventoryBatch copyWith({
    String? id,
    String? productId,
    int? quantity,
    int? remainingQuantity,
    double? costPrice,
    DateTime? expiryDate,
    String? batchNumber,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryBatch(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      costPrice: costPrice ?? this.costPrice,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        quantity,
        remainingQuantity,
        costPrice,
        expiryDate,
        batchNumber,
        tenantId,
        createdAt,
        updatedAt,
      ];
}


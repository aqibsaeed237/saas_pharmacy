import 'package:equatable/equatable.dart';

/// Delivery rate entity
class DeliveryRate extends Equatable {
  final String id;
  final String storeId;
  final double ratePerMileKm;
  final double minimumDistance;
  final double maximumDistance;
  final String deliveryTime; // e.g., "20 minutes"
  final bool isActive;
  final String tenantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DeliveryRate({
    required this.id,
    required this.storeId,
    required this.ratePerMileKm,
    required this.minimumDistance,
    required this.maximumDistance,
    required this.deliveryTime,
    required this.isActive,
    required this.tenantId,
    required this.createdAt,
    this.updatedAt,
  });

  DeliveryRate copyWith({
    String? id,
    String? storeId,
    double? ratePerMileKm,
    double? minimumDistance,
    double? maximumDistance,
    String? deliveryTime,
    bool? isActive,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryRate(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      ratePerMileKm: ratePerMileKm ?? this.ratePerMileKm,
      minimumDistance: minimumDistance ?? this.minimumDistance,
      maximumDistance: maximumDistance ?? this.maximumDistance,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      isActive: isActive ?? this.isActive,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        storeId,
        ratePerMileKm,
        minimumDistance,
        maximumDistance,
        deliveryTime,
        isActive,
        tenantId,
        createdAt,
        updatedAt,
      ];
}


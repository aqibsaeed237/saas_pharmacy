import 'package:equatable/equatable.dart';

/// Add-on entity
class Addon extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final double price;
  final String? imageUrl;
  final bool isActive;
  final String tenantId;
  final String? storeId; // Store/Branch ID
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Addon({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.price,
    this.imageUrl,
    required this.isActive,
    required this.tenantId,
    this.storeId,
    required this.createdAt,
    this.updatedAt,
  });

  Addon copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    bool? isActive,
    String? tenantId,
    String? storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Addon(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      tenantId: tenantId ?? this.tenantId,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        price,
        imageUrl,
        isActive,
        tenantId,
        storeId,
        createdAt,
        updatedAt,
      ];
}


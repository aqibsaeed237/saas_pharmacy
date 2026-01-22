import 'package:equatable/equatable.dart';

/// Ingredient entity
class Ingredient extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final String tenantId;
  final String? storeId; // Store/Branch ID
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Ingredient({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isActive,
    required this.tenantId,
    this.storeId,
    required this.createdAt,
    this.updatedAt,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isActive,
    String? tenantId,
    String? storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
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
        imageUrl,
        isActive,
        tenantId,
        storeId,
        createdAt,
        updatedAt,
      ];
}


import 'package:equatable/equatable.dart';

/// Category entity
class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? shortDescription;
  final String? categoryNote; // Optional category note
  final String? color; // Hex color for UI
  final String? imageUrl; // Category image
  final int? sorting; // Sorting ID
  final double? percentageDiscount; // Optional percentage discount
  final bool isOpenAllDay; // Is open all day (for timing-based categories)
  final String tenantId;
  final String? storeId; // Store/Branch ID
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.shortDescription,
    this.categoryNote,
    this.color,
    this.imageUrl,
    this.sorting,
    this.percentageDiscount,
    this.isOpenAllDay = false,
    required this.tenantId,
    this.storeId,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    String? categoryNote,
    String? color,
    String? imageUrl,
    int? sorting,
    double? percentageDiscount,
    bool? isOpenAllDay,
    String? tenantId,
    String? storeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      categoryNote: categoryNote ?? this.categoryNote,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      sorting: sorting ?? this.sorting,
      percentageDiscount: percentageDiscount ?? this.percentageDiscount,
      isOpenAllDay: isOpenAllDay ?? this.isOpenAllDay,
      tenantId: tenantId ?? this.tenantId,
      storeId: storeId ?? this.storeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        shortDescription,
        categoryNote,
        color,
        imageUrl,
        sorting,
        percentageDiscount,
        isOpenAllDay,
        tenantId,
        storeId,
        isActive,
        createdAt,
        updatedAt,
      ];
}


import 'package:equatable/equatable.dart';

/// Product entity
class Product extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? barcode;
  final String? sku;
  final double price;
  final double? costPrice;
  final String? category;
  final String? imageUrl;
  final String tenantId;
  final String? storeId; // Store/Branch ID
  final bool isActive;
  final bool isAddonItem;
  final String? availability; // Available, Out of Stock, etc.
  final int? sort;
  final String? allergyNotes;
  final List<String>? ingredientIds; // List of ingredient IDs
  final double? percentageDiscount;
  final List<String>? productSizes; // Product size variants
  final String? deliveryRateId;
  final String? riderId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    this.barcode,
    this.sku,
    required this.price,
    this.costPrice,
    this.category,
    this.imageUrl,
    required this.tenantId,
    this.storeId,
    required this.isActive,
    this.isAddonItem = false,
    this.availability,
    this.sort,
    this.allergyNotes,
    this.ingredientIds,
    this.percentageDiscount,
    this.productSizes,
    this.deliveryRateId,
    this.riderId,
    required this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    String? sku,
    double? price,
    double? costPrice,
    String? category,
    String? imageUrl,
    String? tenantId,
    String? storeId,
    bool? isActive,
    bool? isAddonItem,
    String? availability,
    int? sort,
    String? allergyNotes,
    List<String>? ingredientIds,
    double? percentageDiscount,
    List<String>? productSizes,
    String? deliveryRateId,
    String? riderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      tenantId: tenantId ?? this.tenantId,
      storeId: storeId ?? this.storeId,
      isActive: isActive ?? this.isActive,
      isAddonItem: isAddonItem ?? this.isAddonItem,
      availability: availability ?? this.availability,
      sort: sort ?? this.sort,
      allergyNotes: allergyNotes ?? this.allergyNotes,
      ingredientIds: ingredientIds ?? this.ingredientIds,
      percentageDiscount: percentageDiscount ?? this.percentageDiscount,
      productSizes: productSizes ?? this.productSizes,
      deliveryRateId: deliveryRateId ?? this.deliveryRateId,
      riderId: riderId ?? this.riderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        barcode,
        sku,
        price,
        costPrice,
        category,
        imageUrl,
        tenantId,
        storeId,
        isActive,
        isAddonItem,
        availability,
        sort,
        allergyNotes,
        ingredientIds,
        percentageDiscount,
        productSizes,
        deliveryRateId,
        riderId,
        createdAt,
        updatedAt,
      ];
}


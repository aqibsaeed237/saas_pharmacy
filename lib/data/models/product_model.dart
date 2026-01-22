import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

/// Product model (DTO)
@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    super.barcode,
    super.sku,
    required super.price,
    super.costPrice,
    super.category,
    super.imageUrl,
    required super.tenantId,
    required super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      barcode: product.barcode,
      sku: product.sku,
      price: product.price,
      costPrice: product.costPrice,
      category: product.category,
      imageUrl: product.imageUrl,
      tenantId: product.tenantId,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      barcode: barcode,
      sku: sku,
      price: price,
      costPrice: costPrice,
      category: category,
      imageUrl: imageUrl,
      tenantId: tenantId,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}


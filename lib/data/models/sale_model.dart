import '../../domain/entities/sale.dart';
import '../../core/constants/app_enums.dart';

/// Sale model (DTO)
/// Note: JSON serialization will be added when backend is ready
class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    required super.invoiceNumber,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.tax,
    required super.total,
    required super.paymentMethod,
    super.customerName,
    super.customerPhone,
    required super.staffId,
    required super.tenantId,
    required super.createdAt,
    super.updatedAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    // Temporary implementation - will be generated when backend is ready
    return SaleModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      items: (json['items'] as List)
          .map((item) => SaleItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      staffId: json['staff_id'] as String,
      tenantId: json['tenant_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Temporary implementation - will be generated when backend is ready
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'items': items.map((item) => (item as SaleItemModel).toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'payment_method': paymentMethod.name,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'staff_id': staffId,
      'tenant_id': tenantId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Sale toEntity() {
    return Sale(
      id: id,
      invoiceNumber: invoiceNumber,
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      customerName: customerName,
      customerPhone: customerPhone,
      staffId: staffId,
      tenantId: tenantId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Sale item model (DTO)
class SaleItemModel extends SaleItem {
  const SaleItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.discount,
    required super.total,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'total': total,
    };
  }
}

import 'package:equatable/equatable.dart';
import '../../core/constants/app_enums.dart';

/// Sale entity
class Sale extends Equatable {
  final String id;
  final String invoiceNumber;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final PaymentMethod paymentMethod;
  final String? customerName;
  final String? customerPhone;
  final String staffId;
  final String tenantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Sale({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.customerName,
    this.customerPhone,
    required this.staffId,
    required this.tenantId,
    required this.createdAt,
    this.updatedAt,
  });

  Sale copyWith({
    String? id,
    String? invoiceNumber,
    List<SaleItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    PaymentMethod? paymentMethod,
    String? customerName,
    String? customerPhone,
    String? staffId,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      staffId: staffId ?? this.staffId,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        items,
        subtotal,
        discount,
        tax,
        total,
        paymentMethod,
        customerName,
        customerPhone,
        staffId,
        tenantId,
        createdAt,
        updatedAt,
      ];
}

/// Sale item entity
class SaleItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double total;

  const SaleItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.total,
  });

  @override
  List<Object> get props => [
        id,
        productId,
        productName,
        quantity,
        unitPrice,
        discount,
        total,
      ];
}


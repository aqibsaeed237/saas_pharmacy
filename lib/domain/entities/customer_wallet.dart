import 'package:equatable/equatable.dart';

/// Customer wallet entity
class CustomerWallet extends Equatable {
  final String id;
  final String customerId;
  final double balance;
  final double creditLimit;
  final bool isActive;
  final String tenantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomerWallet({
    required this.id,
    required this.customerId,
    required this.balance,
    required this.creditLimit,
    required this.isActive,
    required this.tenantId,
    required this.createdAt,
    this.updatedAt,
  });

  CustomerWallet copyWith({
    String? id,
    String? customerId,
    double? balance,
    double? creditLimit,
    bool? isActive,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerWallet(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      isActive: isActive ?? this.isActive,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        balance,
        creditLimit,
        isActive,
        tenantId,
        createdAt,
        updatedAt,
      ];
}


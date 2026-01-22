import 'package:equatable/equatable.dart';

/// Payment method types
enum PaymentMethodEntityType {
  cash,
  card,
  bankTransfer,
  wallet,
  other,
}

/// Payment method entity
class PaymentMethodEntity extends Equatable {
  final String id;
  final String? customerId; // null for store-wide payment methods
  final PaymentMethodEntityType type;
  final String name;
  final String? cardNumber; // Last 4 digits for cards
  final String? cardHolderName;
  final String? bankName;
  final String? accountNumber;
  final bool isDefault;
  final bool isActive;
  final String tenantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentMethodEntity({
    required this.id,
    this.customerId,
    required this.type,
    required this.name,
    this.cardNumber,
    this.cardHolderName,
    this.bankName,
    this.accountNumber,
    required this.isDefault,
    required this.isActive,
    required this.tenantId,
    required this.createdAt,
    this.updatedAt,
  });

  PaymentMethodEntity copyWith({
    String? id,
    String? customerId,
    PaymentMethodEntityType? type,
    String? name,
    String? cardNumber,
    String? cardHolderName,
    String? bankName,
    String? accountNumber,
    bool? isDefault,
    bool? isActive,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isDefault: isDefault ?? this.isDefault,
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
        type,
        name,
        cardNumber,
        cardHolderName,
        bankName,
        accountNumber,
        isDefault,
        isActive,
        tenantId,
        createdAt,
        updatedAt,
      ];
}


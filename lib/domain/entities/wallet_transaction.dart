import 'package:equatable/equatable.dart';

/// Wallet transaction types
enum TransactionType {
  credit,
  debit,
  topUp,
  payment,
  refund,
}

/// Wallet transaction entity
class WalletTransaction extends Equatable {
  final String id;
  final String walletId;
  final String customerId;
  final TransactionType type;
  final double amount;
  final String? description;
  final String? referenceId; // Sale ID, Purchase ID, etc.
  final String? referenceType; // 'sale', 'purchase', 'topup', etc.
  final String tenantId;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.customerId,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    this.referenceType,
    required this.tenantId,
    required this.createdAt,
  });

  WalletTransaction copyWith({
    String? id,
    String? walletId,
    String? customerId,
    TransactionType? type,
    double? amount,
    String? description,
    String? referenceId,
    String? referenceType,
    String? tenantId,
    DateTime? createdAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        walletId,
        customerId,
        type,
        amount,
        description,
        referenceId,
        referenceType,
        tenantId,
        createdAt,
      ];
}


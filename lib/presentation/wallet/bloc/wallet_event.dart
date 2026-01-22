part of 'wallet_bloc.dart';

/// Wallet events
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerWallet extends WalletEvent {
  final String customerId;

  const LoadCustomerWallet(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadWalletTransactions extends WalletEvent {
  final String customerId;

  const LoadWalletTransactions(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class TopUpWallet extends WalletEvent {
  final String customerId;
  final double amount;
  final String? description;

  const TopUpWallet({
    required this.customerId,
    required this.amount,
    this.description,
  });

  @override
  List<Object?> get props => [customerId, amount, description];
}

class AddWalletTransaction extends WalletEvent {
  final String customerId;
  final TransactionType type;
  final double amount;
  final String? description;
  final String? referenceId;
  final String? referenceType;

  const AddWalletTransaction({
    required this.customerId,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    this.referenceType,
  });

  @override
  List<Object?> get props => [
        customerId,
        type,
        amount,
        description,
        referenceId,
        referenceType,
      ];
}


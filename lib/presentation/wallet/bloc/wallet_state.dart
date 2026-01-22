part of 'wallet_bloc.dart';

/// Wallet states
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final CustomerWallet wallet;

  const WalletLoaded({required this.wallet});

  @override
  List<Object?> get props => [wallet];
}

class WalletTransactionsLoading extends WalletState {}

class WalletTransactionsLoaded extends WalletState {
  final List<WalletTransaction> transactions;

  const WalletTransactionsLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class WalletTopUpSuccess extends WalletState {}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}


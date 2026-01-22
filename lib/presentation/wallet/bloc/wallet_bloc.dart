import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/customer_wallet.dart';
import '../../../domain/entities/wallet_transaction.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

/// Wallet BLoC
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<LoadCustomerWallet>(_onLoadCustomerWallet);
    on<LoadWalletTransactions>(_onLoadWalletTransactions);
    on<TopUpWallet>(_onTopUpWallet);
    on<AddWalletTransaction>(_onAddWalletTransaction);
  }

  // Mock wallet data
  final Map<String, CustomerWallet> _mockWallets = {
    '1': CustomerWallet(
      id: 'wallet1',
      customerId: '1',
      balance: 500.0,
      creditLimit: 1000.0,
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    '2': CustomerWallet(
      id: 'wallet2',
      customerId: '2',
      balance: 250.0,
      creditLimit: 500.0,
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  };

  // Mock transactions
  final List<WalletTransaction> _mockTransactions = [
    WalletTransaction(
      id: 't1',
      walletId: 'wallet1',
      customerId: '1',
      type: TransactionType.topUp,
      amount: 500.0,
      description: 'Top-up via cash',
      referenceType: 'topup',
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    WalletTransaction(
      id: 't2',
      walletId: 'wallet1',
      customerId: '1',
      type: TransactionType.debit,
      amount: 150.0,
      description: 'Purchase #1234',
      referenceId: 'sale1234',
      referenceType: 'sale',
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  void _onLoadCustomerWallet(
    LoadCustomerWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    final wallet = _mockWallets[event.customerId];
    if (wallet != null) {
      emit(WalletLoaded(wallet: wallet));
    } else {
      emit(WalletError('Wallet not found'));
    }
  }

  void _onLoadWalletTransactions(
    LoadWalletTransactions event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletTransactionsLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    final transactions = _mockTransactions
        .where((t) => t.customerId == event.customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    emit(WalletTransactionsLoaded(transactions: transactions));
  }

  void _onTopUpWallet(
    TopUpWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    final wallet = _mockWallets[event.customerId];
    if (wallet != null) {
      final updatedWallet = wallet.copyWith(
        balance: wallet.balance + event.amount,
        updatedAt: DateTime.now(),
      );
      _mockWallets[event.customerId] = updatedWallet;
      
      // Add transaction
      final transaction = WalletTransaction(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        walletId: updatedWallet.id,
        customerId: event.customerId,
        type: TransactionType.topUp,
        amount: event.amount,
        description: event.description ?? 'Top-up',
        referenceType: 'topup',
        tenantId: wallet.tenantId,
        createdAt: DateTime.now(),
      );
      _mockTransactions.insert(0, transaction);
      
      emit(WalletLoaded(wallet: updatedWallet));
      emit(WalletTopUpSuccess());
    } else {
      emit(WalletError('Wallet not found'));
    }
  }

  void _onAddWalletTransaction(
    AddWalletTransaction event,
    Emitter<WalletState> emit,
  ) async {
    final wallet = _mockWallets[event.customerId];
    if (wallet != null) {
      final updatedBalance = event.type == TransactionType.credit ||
              event.type == TransactionType.topUp
          ? wallet.balance + event.amount
          : wallet.balance - event.amount;
      
      final updatedWallet = wallet.copyWith(
        balance: updatedBalance,
        updatedAt: DateTime.now(),
      );
      _mockWallets[event.customerId] = updatedWallet;
      
      final transaction = WalletTransaction(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        walletId: wallet.id,
        customerId: event.customerId,
        type: event.type,
        amount: event.amount,
        description: event.description,
        referenceId: event.referenceId,
        referenceType: event.referenceType,
        tenantId: wallet.tenantId,
        createdAt: DateTime.now(),
      );
      _mockTransactions.insert(0, transaction);
      
      emit(WalletLoaded(wallet: updatedWallet));
    }
  }
}


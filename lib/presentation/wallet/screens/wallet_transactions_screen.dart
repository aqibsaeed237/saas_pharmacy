import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/wallet_transaction.dart';
import '../bloc/wallet_bloc.dart';

/// Wallet transactions screen
class WalletTransactionsScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const WalletTransactionsScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<WalletTransactionsScreen> createState() => _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadWalletTransactions(widget.customerId));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${loc?.translate('transactions') ?? 'Transactions'} - ${widget.customerName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletTransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is WalletTransactionsLoaded) {
            if (state.transactions.isEmpty) {
              return Center(
                child: Text(loc?.translate('noTransactions') ?? 'No transactions found'),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                return _buildTransactionCard(context, transaction, loc);
              },
            );
          }
          
          return Center(
            child: Text(loc?.translate('error') ?? 'Error'),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    WalletTransaction transaction,
    AppLocalizations? loc,
  ) {
    final isCredit = transaction.type == TransactionType.credit ||
        transaction.type == TransactionType.topUp;
    final color = isCredit ? Colors.green : Colors.red;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.description ?? transaction.type.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM dd, yyyy HH:mm').format(transaction.createdAt),
            ),
            if (transaction.referenceId != null)
              Text(
                '${loc?.translate('reference') ?? 'Reference'}: ${transaction.referenceId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}


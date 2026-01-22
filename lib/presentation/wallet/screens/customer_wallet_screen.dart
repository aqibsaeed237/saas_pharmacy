import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../bloc/wallet_bloc.dart';
import 'wallet_transactions_screen.dart';
import 'top_up_screen.dart';

/// Customer wallet screen
class CustomerWalletScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerWalletScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CustomerWalletScreen> createState() => _CustomerWalletScreenState();
}

class _CustomerWalletScreenState extends State<CustomerWalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadCustomerWallet(widget.customerId));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${loc?.translate('wallet') ?? 'Wallet'} - ${widget.customerName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push(
                '/wallet/transactions',
                extra: {
                  'customerId': widget.customerId,
                  'customerName': widget.customerName,
                },
              );
            },
            tooltip: loc?.translate('transactions') ?? 'Transactions',
          ),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is WalletLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Balance Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            loc?.translate('currentBalance') ?? 'Current Balance',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(state.wallet.balance),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    loc?.translate('creditLimit') ?? 'Credit Limit',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    CurrencyFormatter.format(state.wallet.creditLimit),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    loc?.translate('availableCredit') ?? 'Available Credit',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                      state.wallet.creditLimit - state.wallet.balance,
                                    ),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.green,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Actions
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '/wallet/topup',
                        extra: {
                          'customerId': widget.customerId,
                          'customerName': widget.customerName,
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(loc?.translate('topUp') ?? 'Top Up'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        '/wallet/transactions',
                        extra: {
                          'customerId': widget.customerId,
                          'customerName': widget.customerName,
                        },
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: Text(loc?.translate('viewTransactions') ?? 'View Transactions'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Center(
            child: Text(loc?.translate('error') ?? 'Error'),
          );
        },
      ),
    );
  }
}


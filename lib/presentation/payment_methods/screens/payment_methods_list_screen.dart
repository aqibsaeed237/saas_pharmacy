import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/payment_method.dart' as entity;
import '../bloc/payment_method_bloc.dart';
import 'payment_method_form_screen.dart';

/// Payment methods list screen
class PaymentMethodsListScreen extends StatefulWidget {
  final String? customerId;

  const PaymentMethodsListScreen({super.key, this.customerId});

  @override
  State<PaymentMethodsListScreen> createState() => _PaymentMethodsListScreenState();
}

class _PaymentMethodsListScreenState extends State<PaymentMethodsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentMethodBloc>().add(LoadPaymentMethods(customerId: widget.customerId));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('paymentMethods') ?? 'Payment Methods'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(
                '/payment-methods/add',
                extra: {'customerId': widget.customerId},
              );
            },
            tooltip: loc?.translate('addPaymentMethod') ?? 'Add Payment Method',
          ),
        ],
      ),
      body: BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
        builder: (context, state) {
          if (state is PaymentMethodLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is PaymentMethodsLoaded) {
            if (state.paymentMethods.isEmpty) {
              return Center(
                child: Text(loc?.translate('noPaymentMethods') ?? 'No payment methods found'),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.paymentMethods.length,
              itemBuilder: (context, index) {
                final method = state.paymentMethods[index];
                return _buildPaymentMethodCard(context, method, loc);
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

  Widget _buildPaymentMethodCard(
    BuildContext context,
    entity.PaymentMethodEntity method,
    AppLocalizations? loc,
  ) {
    IconData icon;
    switch (method.type) {
      case entity.PaymentMethodEntityType.cash:
        icon = Icons.money;
        break;
      case entity.PaymentMethodEntityType.card:
        icon = Icons.credit_card;
        break;
      case entity.PaymentMethodEntityType.bankTransfer:
        icon = Icons.account_balance;
        break;
      case entity.PaymentMethodEntityType.wallet:
        icon = Icons.account_balance_wallet;
        break;
      default:
        icon = Icons.payment;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          method.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(method.type.name.toUpperCase()),
            if (method.cardNumber != null)
              Text('****${method.cardNumber}'),
            if (method.bankName != null)
              Text(method.bankName!),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (method.isDefault)
              Chip(
                label: Text(loc?.translate('default') ?? 'Default'),
                labelStyle: const TextStyle(fontSize: 10),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(loc?.translate('edit') ?? 'Edit'),
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      context.push(
                        '/payment-methods/edit',
                        extra: {'method': method},
                      );
                    });
                  },
                ),
                if (!method.isDefault)
                  PopupMenuItem(
                    child: Text(loc?.translate('setAsDefault') ?? 'Set as Default'),
                    onTap: () {
                      context.read<PaymentMethodBloc>().add(
                            SetDefaultPaymentMethod(method.id),
                          );
                    },
                  ),
                PopupMenuItem(
                  child: Text(
                    loc?.translate('delete') ?? 'Delete',
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(loc?.translate('delete') ?? 'Delete'),
                        content: Text(
                          loc?.translate('deletePaymentMethodConfirmation') ??
                              'Are you sure you want to delete this payment method?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(loc?.translate('cancel') ?? 'Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<PaymentMethodBloc>().add(
                                    DeletePaymentMethod(method.id),
                                  );
                              context.pop();
                            },
                            child: Text(
                              loc?.translate('delete') ?? 'Delete',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


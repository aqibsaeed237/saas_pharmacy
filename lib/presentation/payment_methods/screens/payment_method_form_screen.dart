import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/payment_method.dart' as entity;
import '../bloc/payment_method_bloc.dart';

/// Payment method form screen (add/edit)
class PaymentMethodFormScreen extends StatefulWidget {
  final entity.PaymentMethodEntity? method;
  final String? customerId;

  const PaymentMethodFormScreen({
    super.key,
    this.method,
    this.customerId,
  });

  @override
  State<PaymentMethodFormScreen> createState() => _PaymentMethodFormScreenState();
}

class _PaymentMethodFormScreenState extends State<PaymentMethodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late entity.PaymentMethodEntityType _selectedType;
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.method != null) {
      _selectedType = widget.method!.type;
      _nameController.text = widget.method!.name;
      _cardNumberController.text = widget.method!.cardNumber ?? '';
      _cardHolderController.text = widget.method!.cardHolderName ?? '';
      _bankNameController.text = widget.method!.bankName ?? '';
      _accountNumberController.text = widget.method!.accountNumber ?? '';
      _isDefault = widget.method!.isDefault;
    } else {
      _selectedType = entity.PaymentMethodEntityType.cash;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (widget.method != null) {
        context.read<PaymentMethodBloc>().add(
              UpdatePaymentMethod(
                id: widget.method!.id,
                name: _nameController.text,
                cardNumber: _cardNumberController.text.isEmpty
                    ? null
                    : _cardNumberController.text,
                cardHolderName: _cardHolderController.text.isEmpty
                    ? null
                    : _cardHolderController.text,
                bankName: _bankNameController.text.isEmpty
                    ? null
                    : _bankNameController.text,
                accountNumber: _accountNumberController.text.isEmpty
                    ? null
                    : _accountNumberController.text,
                isDefault: _isDefault,
              ),
            );
      } else {
        context.read<PaymentMethodBloc>().add(
              AddPaymentMethod(
                customerId: widget.customerId,
                type: _selectedType,
                name: _nameController.text,
                cardNumber: _cardNumberController.text.isEmpty
                    ? null
                    : _cardNumberController.text,
                cardHolderName: _cardHolderController.text.isEmpty
                    ? null
                    : _cardHolderController.text,
                bankName: _bankNameController.text.isEmpty
                    ? null
                    : _bankNameController.text,
                accountNumber: _accountNumberController.text.isEmpty
                    ? null
                    : _accountNumberController.text,
                isDefault: _isDefault,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.method != null
              ? loc?.translate('editPaymentMethod') ?? 'Edit Payment Method'
              : loc?.translate('addPaymentMethod') ?? 'Add Payment Method',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
        listener: (context, state) {
          if (state is PaymentMethodAdded || state is PaymentMethodUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.method != null
                      ? loc?.translate('paymentMethodUpdated') ?? 'Payment method updated'
                      : loc?.translate('paymentMethodAdded') ?? 'Payment method added',
                ),
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.method == null)
                    DropdownButtonFormField<entity.PaymentMethodEntityType>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: loc?.translate('type') ?? 'Type',
                        border: const OutlineInputBorder(),
                      ),
                      items: entity.PaymentMethodEntityType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  if (widget.method == null) const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: loc?.translate('name') ?? 'Name',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc?.translate('pleaseEnterName') ?? 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedType == entity.PaymentMethodEntityType.card ||
                      widget.method?.type == entity.PaymentMethodEntityType.card) ...[
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: loc?.translate('cardNumber') ?? 'Card Number (Last 4 digits)',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cardHolderController,
                      decoration: InputDecoration(
                        labelText: loc?.translate('cardHolderName') ?? 'Card Holder Name',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_selectedType == entity.PaymentMethodEntityType.bankTransfer ||
                      widget.method?.type == entity.PaymentMethodEntityType.bankTransfer) ...[
                    TextFormField(
                      controller: _bankNameController,
                      decoration: InputDecoration(
                        labelText: loc?.translate('bankName') ?? 'Bank Name',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: InputDecoration(
                        labelText: loc?.translate('accountNumber') ?? 'Account Number',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  CheckboxListTile(
                    title: Text(loc?.translate('setAsDefault') ?? 'Set as Default'),
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() => _isDefault = value ?? false);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is PaymentMethodLoading ? null : _handleSave,
                    child: state is PaymentMethodLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(loc?.translate('save') ?? 'Save'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


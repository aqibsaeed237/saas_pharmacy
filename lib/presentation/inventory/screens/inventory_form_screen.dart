import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Inventory form screen (Add stock)
class InventoryFormScreen extends StatefulWidget {
  final String? batchId;
  
  const InventoryFormScreen({super.key, this.batchId});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costPriceController = TextEditingController();
  DateTime? _expiryDate;
  String? _selectedProductId;

  @override
  void dispose() {
    _productController.dispose();
    _batchNumberController.dispose();
    _quantityController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _handleSave() {
    final loc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate() && _expiryDate != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc?.translate('stockAddedSuccessfully') ?? 'Stock added successfully')),
      );
      context.pop();
    } else if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc?.translate('pleaseSelectExpiryDate') ?? 'Please select expiry date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final loc = AppLocalizations.of(context);
            return Text(widget.batchId != null 
                ? (loc?.translate('editInventory') ?? 'Edit Inventory')
                : (loc?.translate('addStock') ?? 'Add Stock'));
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product selection
              Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(context);
                  return Column(
                    children: [
                      AppTextField(
                        controller: _productController,
                        label: loc?.translate('product') ?? 'Product',
                        prefixIcon: Icons.medication,
                        readOnly: true,
                        onTap: () {
                          // Show product picker
                          _productController.text = 'Paracetamol 500mg';
                          _selectedProductId = '1';
                        },
                        validator: (v) => Validators.required(v, loc?.translate('product') ?? 'Product'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      // Batch Number
                      AppTextField(
                        controller: _batchNumberController,
                        label: loc?.translate('batchNumber') ?? 'Batch Number',
                        prefixIcon: Icons.qr_code,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      // Quantity
                      AppTextField(
                        controller: _quantityController,
                        label: loc?.translate('quantity') ?? 'Quantity',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.numbers,
                        validator: (v) => Validators.positiveNumber(v, loc?.translate('quantity') ?? 'Quantity'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      // Cost Price
                      AppTextField(
                        controller: _costPriceController,
                        label: loc?.translate('costPrice') ?? 'Cost Price per Unit',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.attach_money,
                        validator: (v) => Validators.positiveNumber(v, loc?.translate('costPrice') ?? 'Cost Price'),
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Expiry Date
              Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(context);
                  return InkWell(
                    onTap: _selectExpiryDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: loc?.translate('expiryDate') ?? 'Expiry Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _expiryDate != null
                            ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                            : (loc?.translate('selectExpiryDate') ?? 'Select expiry date'),
                        style: TextStyle(
                          color: _expiryDate != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Save button
              Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(context);
                  return AppButton(
                    label: widget.batchId != null ? (loc?.translate('updateStock') ?? 'Update Stock') : (loc?.translate('addStock') ?? 'Add Stock'),
                    onPressed: _handleSave,
                    icon: widget.batchId != null ? Icons.save : Icons.add,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


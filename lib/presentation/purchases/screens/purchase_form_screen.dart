import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../products/bloc/product_bloc.dart';
import '../../products/bloc/product_event.dart';
import '../../products/bloc/product_state.dart';

/// Purchase item model
class PurchaseItem {
  final String id;
  String productId;
  String productName;
  String? batchNumber;
  int quantity;
  double costPrice;
  double sellingPrice;
  double discount;
  DateTime? expiryDate;
  String? location;

  PurchaseItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.batchNumber,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    this.discount = 0.0,
    this.expiryDate,
    this.location,
  });

  double get netPrice => costPrice - discount;
  double get total => netPrice * quantity;
}

/// Purchase form screen
class PurchaseFormScreen extends StatefulWidget {
  final String? purchaseId;
  
  const PurchaseFormScreen({super.key, this.purchaseId});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  
  List<PurchaseItem> _items = [];
  List<File> _attachedFiles = [];
  final ImagePicker _imagePicker = ImagePicker();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _purchaseDateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (widget.purchaseId != null) {
      _loadPurchaseData();
    }
    // Load products
    context.read<ProductBloc>().add(const LoadProducts());
  }

  void _loadPurchaseData() {
    // Mock data loading for edit mode
    setState(() {
      _supplierController.text = 'ABC Pharmaceuticals';
      _invoiceNumberController.text = 'INV-${widget.purchaseId}';
      _notesController.text = 'Purchase notes';
      // Add mock items
      _items = [
        PurchaseItem(
          id: '1',
          productId: 'prod1',
          productName: 'Paracetamol 500mg',
          batchNumber: 'BATCH001',
          quantity: 100,
          costPrice: 5.0,
          sellingPrice: 8.0,
          discount: 0.5,
          expiryDate: DateTime.now().add(const Duration(days: 365)),
          location: 'Shelf A1',
        ),
      ];
    });
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _purchaseDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showAddItemDialog() {
    final loc = AppLocalizations.of(context);
    final productBloc = context.read<ProductBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: productBloc,
        child: _AddItemDialog(
          onAdd: (item) {
            setState(() {
              _items.add(item);
            });
          },
        ),
      ),
    );
  }

  void _editItem(int index) {
    final item = _items[index];
    final productBloc = context.read<ProductBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: productBloc,
        child: _AddItemDialog(
          item: item,
          onAdd: (updatedItem) {
            setState(() {
              _items[index] = updatedItem;
            });
          },
        ),
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _attachedFiles.add(File(image.path));
        });
      }
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc?.translate('errorPickingImage') ?? 'Error picking image'}: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _attachedFiles.add(File(file.path!));
            }
          }
        });
      }
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc?.translate('errorPickingFile') ?? 'Error picking file'}: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.translate('addAtLeastOneItem') ?? 'Please add at least one item')),
        );
        return;
      }

      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc?.translate('purchaseCreated') ?? 'Purchase created successfully')),
      );
      context.pop();
    }
  }

  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  double get _totalDiscount {
    return _items.fold(0.0, (sum, item) => sum + (item.discount * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.purchaseId != null 
            ? loc?.translate('editPurchase') ?? 'Edit Purchase'
            : loc?.translate('newPurchase') ?? 'New Purchase'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Supplier
              AppTextField(
                controller: _supplierController,
                label: loc?.translate('supplierName') ?? 'Supplier Name',
                prefixIcon: Icons.business,
                validator: (v) => Validators.required(v, loc?.translate('supplierName') ?? 'Supplier Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Invoice Number
              AppTextField(
                controller: _invoiceNumberController,
                label: loc?.translate('invoiceNumber') ?? 'Invoice Number',
                prefixIcon: Icons.receipt,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Purchase Date
              AppTextField(
                controller: _purchaseDateController,
                label: loc?.translate('purchaseDate') ?? 'Purchase Date',
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                controller: _notesController,
                label: loc?.translate('notes') ?? 'Notes',
                maxLines: 3,
                prefixIcon: Icons.note_outlined,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Items section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc?.translate('items') ?? 'Items',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: _showAddItemDialog,
                            tooltip: loc?.translate('addItem') ?? 'Add Item',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  loc?.translate('noItemsAdded') ?? 'No items added yet',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _showAddItemDialog,
                                  icon: const Icon(Icons.add),
                                  label: Text(loc?.translate('addItem') ?? 'Add Item'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                item.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${loc?.translate('quantity') ?? 'Qty'}: ${item.quantity}'),
                                  if (item.batchNumber != null)
                                    Text('${loc?.translate('batch') ?? 'Batch'}: ${item.batchNumber}'),
                                  Text('${loc?.translate('costPrice') ?? 'Cost'}: ${CurrencyFormatter.format(item.costPrice)}'),
                                  Text('${loc?.translate('sellingPrice') ?? 'Selling'}: ${CurrencyFormatter.format(item.sellingPrice)}'),
                                  if (item.discount > 0)
                                    Text('${loc?.translate('discount') ?? 'Discount'}: ${CurrencyFormatter.format(item.discount)}'),
                                  if (item.expiryDate != null)
                                    Text('${loc?.translate('expiryDate') ?? 'Expiry'}: ${DateFormat('yyyy-MM-dd').format(item.expiryDate!)}'),
                                  Text(
                                    '${loc?.translate('total') ?? 'Total'}: ${CurrencyFormatter.format(item.total)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editItem(index),
                                    tooltip: loc?.translate('edit') ?? 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeItem(index),
                                    tooltip: loc?.translate('delete') ?? 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      if (_items.isNotEmpty) ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loc?.translate('totalAmount') ?? 'Total Amount',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                CurrencyFormatter.format(_totalAmount),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Attached files section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc?.translate('attachedFiles') ?? 'Attached Files',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.image),
                                onPressed: _pickImage,
                                tooltip: loc?.translate('addImage') ?? 'Add Image',
                              ),
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                onPressed: _pickFile,
                                tooltip: loc?.translate('addFile') ?? 'Add File',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_attachedFiles.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              loc?.translate('noFilesAttached') ?? 'No files attached',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ),
                        )
                      else
                        ..._attachedFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return ListTile(
                            leading: const Icon(Icons.attachment),
                            title: Text(file.path.split('/').last),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFile(index),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              AppButton(
                label: widget.purchaseId != null
                    ? loc?.translate('updatePurchase') ?? 'Update Purchase'
                    : loc?.translate('createPurchase') ?? 'Create Purchase',
                onPressed: _handleSave,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding/editing purchase items
class _AddItemDialog extends StatefulWidget {
  final PurchaseItem? item;
  final Function(PurchaseItem) onAdd;

  const _AddItemDialog({this.item, required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  String _productName = '';
  final _batchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _expiryDate;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _selectedProductId = widget.item!.productId;
      _productName = widget.item!.productName;
      _batchController.text = widget.item!.batchNumber ?? '';
      _quantityController.text = widget.item!.quantity.toString();
      _costPriceController.text = widget.item!.costPrice.toString();
      _sellingPriceController.text = widget.item!.sellingPrice.toString();
      _discountController.text = widget.item!.discount.toString();
      _locationController.text = widget.item!.location ?? '';
      _expiryDate = widget.item!.expiryDate;
    }
    context.read<ProductBloc>().add(const LoadProducts());
  }

  @override
  void dispose() {
    _batchController.dispose();
    _quantityController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _discountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProductId == null || _productName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product')),
        );
        return;
      }

      final item = PurchaseItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        productId: _selectedProductId!,
        productName: _productName,
        batchNumber: _batchController.text.isEmpty ? null : _batchController.text,
        quantity: int.parse(_quantityController.text),
        costPrice: double.parse(_costPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        discount: double.tryParse(_discountController.text) ?? 0.0,
        expiryDate: _expiryDate,
        location: _locationController.text.isEmpty ? null : _locationController.text,
      );

      widget.onAdd(item);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.item == null
                    ? loc?.translate('addItem') ?? 'Add Item'
                    : loc?.translate('editItem') ?? 'Edit Item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
              // Product selection
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, productState) {
                  List<dynamic> products = [];
                  if (productState is ProductsLoaded) {
                    products = productState.products;
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    decoration: InputDecoration(
                      labelText: loc?.translate('product') ?? 'Product',
                      prefixIcon: const Icon(Icons.medication),
                      border: const OutlineInputBorder(),
                    ),
                    items: products.map((product) {
                      return DropdownMenuItem<String>(
                        value: product.id,
                        child: Text(product.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value;
                        final product = products.firstWhere((p) => p.id == value);
                        _productName = product.name;
                        if (_costPriceController.text.isEmpty) {
                          _costPriceController.text = (product.costPrice ?? product.price * 0.7).toString();
                        }
                        if (_sellingPriceController.text.isEmpty) {
                          _sellingPriceController.text = product.price.toString();
                        }
                      });
                    },
                    validator: (v) => v == null ? loc?.translate('pleaseSelectProduct') ?? 'Please select a product' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Batch number
              AppTextField(
                controller: _batchController,
                label: loc?.translate('batchNumber') ?? 'Batch Number',
                prefixIcon: Icons.qr_code,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Quantity
              AppTextField(
                controller: _quantityController,
                label: loc?.translate('quantity') ?? 'Quantity',
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.required(v, loc?.translate('quantity') ?? 'Quantity'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Cost price
              AppTextField(
                controller: _costPriceController,
                label: loc?.translate('costPrice') ?? 'Cost Price',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => Validators.required(v, loc?.translate('costPrice') ?? 'Cost Price'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Selling price
              AppTextField(
                controller: _sellingPriceController,
                label: loc?.translate('sellingPrice') ?? 'Selling Price',
                prefixIcon: Icons.price_check,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => Validators.required(v, loc?.translate('sellingPrice') ?? 'Selling Price'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Discount
              AppTextField(
                controller: _discountController,
                label: loc?.translate('discount') ?? 'Discount',
                prefixIcon: Icons.discount,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Expiry date
              InkWell(
                onTap: _selectExpiryDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: loc?.translate('expiryDate') ?? 'Expiry Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    _expiryDate != null
                        ? DateFormat('yyyy-MM-dd').format(_expiryDate!)
                        : loc?.translate('selectDate') ?? 'Select Date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              AppTextField(
                controller: _locationController,
                label: loc?.translate('location') ?? 'Location',
                prefixIcon: Icons.location_on,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc?.translate('cancel') ?? 'Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSave,
                    child: Text(loc?.translate('save') ?? 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

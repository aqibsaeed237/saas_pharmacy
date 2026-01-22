import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/utils/validators.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/bloc/category_event.dart';
import '../../categories/bloc/category_state.dart';

/// Product form screen (Add/Edit)
class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isEditMode = false;
  final ImagePicker _imagePicker = ImagePicker();
  File? _productImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productId != null;
    // Load categories
    context.read<CategoryBloc>().add(const LoadCategories());
    if (_isEditMode) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    // Mock data
    _nameController.text = 'Paracetamol 500mg';
    _descriptionController.text = 'Pain reliever and fever reducer';
    _barcodeController.text = '1234567890123';
    _skuController.text = 'PRC-500';
    _priceController.text = '5.99';
    _costPriceController.text = '3.50';
    _selectedCategoryId = 'cat1';
    _selectedCategoryName = 'Medications';
    _imageUrl = 'https://example.com/product.jpg';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _productImage = File(image.path);
          _imageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.translate('errorPickingImage') ?? 'Error picking image'}: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _productImage = File(image.path);
          _imageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc?.translate('errorTakingPhoto') ?? 'Error taking photo'}: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final loc = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode 
              ? (loc?.translate('productUpdated') ?? 'Product updated')
              : (loc?.translate('productAdded') ?? 'Product added')),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode 
            ? (loc?.translate('editProduct') ?? 'Edit Product')
            : (loc?.translate('addProduct') ?? 'Add Product')),
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
              // Product Image
              Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(context);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc?.translate('image') ?? 'Image',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: Text(loc?.translate('chooseFromGallery') ?? 'Choose from Gallery'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: Text(loc?.translate('takePhoto') ?? 'Take Photo'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _takePhoto();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          child: _productImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    _productImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildImagePlaceholder(context, loc);
                                        },
                                      ),
                                    )
                                  : _buildImagePlaceholder(context, loc),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Name
              AppTextField(
                controller: _nameController,
                label: 'Product Name',
                prefixIcon: Icons.medication,
                validator: (v) => Validators.required(v, 'Product Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Barcode
              AppTextField(
                controller: _barcodeController,
                label: 'Barcode',
                prefixIcon: Icons.qr_code,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // SKU
              AppTextField(
                controller: _skuController,
                label: 'SKU',
                prefixIcon: Icons.inventory_2_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Price
              AppTextField(
                controller: _priceController,
                label: 'Selling Price',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money,
                validator: (v) => Validators.positiveNumber(v, 'Price'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Cost Price
              AppTextField(
                controller: _costPriceController,
                label: 'Cost Price',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.monetization_on_outlined,
                validator: (v) => Validators.positiveNumber(v, 'Cost Price'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  List<dynamic> categories = [];
                  if (state is CategoriesLoaded) {
                    categories = state.categories;
                  }

                  final loc = AppLocalizations.of(context);
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: loc?.translate('category') ?? 'Category',
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    hint: Text(loc?.translate('selectCategory') ?? 'Select a category'),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        if (value != null) {
                          final category = categories.firstWhere((cat) => cat['id'] == value);
                          _selectedCategoryName = category['name'];
                        }
                      });
                    },
                    validator: (v) => v == null ? (loc?.translate('pleaseSelectCategory') ?? 'Please select a category') : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Add Category Link
              Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(context);
                  return TextButton.icon(
                    onPressed: () => context.pushNamed('categoryAdd'),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(loc?.translate('addNewCategory') ?? 'Add New Category'),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Save button
              Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(context);
                  return AppButton(
                    label: _isEditMode ? (loc?.translate('updateProduct') ?? 'Update Product') : (loc?.translate('addProduct') ?? 'Add Product'),
                    onPressed: _handleSave,
                    icon: Icons.save,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, AppLocalizations? loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            loc?.translate('tapToAddImage') ?? 'Tap to add image',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}


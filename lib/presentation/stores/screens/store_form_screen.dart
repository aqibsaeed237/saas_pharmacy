import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/utils/validators.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_text_field.dart';

/// Store form screen (Add/Edit)
class StoreFormScreen extends StatefulWidget {
  final String? storeId;

  const StoreFormScreen({super.key, this.storeId});

  @override
  State<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _storeImage;
  String? _imageUrl;
  bool _isEditMode = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.storeId != null;
    if (_isEditMode) {
      _loadStoreData();
    }
    _countryController.text = 'Pakistan'; // Default
  }

  void _loadStoreData() {
    // Mock data
    _nameController.text = 'Main Pharmacy';
    _descriptionController.text = 'Main branch location';
    _addressLine1Controller.text = '123 Main St';
    _addressLine2Controller.text = 'Near Market';
    _cityController.text = 'Lahore';
    _stateController.text = 'Punjab';
    _postalCodeController.text = '54000';
    _countryController.text = 'Pakistan';
    _phoneController.text = '+92-300-1234567';
    _emailController.text = 'main@pharmacy.com';
    _isActive = true;
    _imageUrl = 'https://example.com/store.jpg';
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
          _storeImage = File(image.path);
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
          _storeImage = File(image.path);
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
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Create store entity and dispatch event
      // For now, just show success
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode 
            ? (loc?.translate('storeUpdated') ?? 'Store updated')
            : (loc?.translate('storeAdded') ?? 'Store added')),
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
          ? (loc?.translate('editStore') ?? 'Edit Store')
          : (loc?.translate('addStore') ?? 'Add Store')),
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
              // Store Image
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
                  child: _storeImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            _storeImage!,
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
              const SizedBox(height: 16),

              // Name
              AppTextField(
                controller: _nameController,
                label: loc?.translate('name') ?? 'Store Name',
                prefixIcon: Icons.store,
                validator: (v) => Validators.required(v, loc?.translate('name') ?? 'Store Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: loc?.translate('description') ?? 'Description',
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Address Line 1
              AppTextField(
                controller: _addressLine1Controller,
                label: loc?.translate('address') ?? 'Address Line 1',
                prefixIcon: Icons.location_on,
                validator: (v) => Validators.required(v, loc?.translate('address') ?? 'Address'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Address Line 2
              AppTextField(
                controller: _addressLine2Controller,
                label: 'Address Line 2 (Optional)',
                prefixIcon: Icons.location_city,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // City
              AppTextField(
                controller: _cityController,
                label: loc?.translate('city') ?? 'City',
                prefixIcon: Icons.location_city,
                validator: (v) => Validators.required(v, loc?.translate('city') ?? 'City'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // State
              AppTextField(
                controller: _stateController,
                label: 'State/Province',
                prefixIcon: Icons.map,
                validator: (v) => Validators.required(v, 'State'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Postal Code
              AppTextField(
                controller: _postalCodeController,
                label: 'Postal Code',
                prefixIcon: Icons.markunread_mailbox,
                validator: (v) => Validators.required(v, 'Postal Code'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Country
              AppTextField(
                controller: _countryController,
                label: loc?.translate('country') ?? 'Country',
                prefixIcon: Icons.public,
                validator: (v) => Validators.required(v, loc?.translate('country') ?? 'Country'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Phone
              AppTextField(
                controller: _phoneController,
                label: loc?.translate('phone') ?? 'Phone',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Email
              AppTextField(
                controller: _emailController,
                label: loc?.translate('email') ?? 'Email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => Validators.email(v),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Active toggle
              SwitchListTile(
                title: Text(loc?.translate('active') ?? 'Active?'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  loc?.translate('submit') ?? 'Submit',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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


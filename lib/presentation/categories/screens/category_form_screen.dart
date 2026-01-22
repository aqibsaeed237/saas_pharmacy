import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/utils/validators.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';

/// Category form screen (Add/Edit)
class CategoryFormScreen extends StatefulWidget {
  final String? categoryId;

  const CategoryFormScreen({super.key, this.categoryId});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _categoryNoteController = TextEditingController();
  final _sortingController = TextEditingController();
  final _percentageDiscountController = TextEditingController();
  final _colorController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _categoryImage;
  String? _imageUrl; // For existing images
  bool _isEditMode = false;
  bool _isActive = true;
  bool _isOpenAllDay = false;

  // Predefined colors
  final List<Color> _predefinedColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
  ];

  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.categoryId != null;
    _colorController.text = '#2196F3';
    if (_isEditMode) {
      _loadCategoryData();
    }
  }

  void _loadCategoryData() {
    // Mock data
    _nameController.text = 'Medications';
    _descriptionController.text = 'Prescription and over-the-counter medications';
    _shortDescriptionController.text = 'Medications category';
    _categoryNoteController.text = 'Special handling required';
    _sortingController.text = '1';
    _percentageDiscountController.text = '10';
    _colorController.text = '#2196F3';
    _selectedColor = Colors.blue;
    _isActive = true;
    _isOpenAllDay = false;
    _imageUrl = 'https://example.com/category.jpg';
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
          _categoryImage = File(image.path);
          _imageUrl = null; // Clear existing URL when new image is picked
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
          _categoryImage = File(image.path);
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

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _categoryNoteController.dispose();
    _sortingController.dispose();
    _percentageDiscountController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_isEditMode) {
        context.read<CategoryBloc>().add(
              UpdateCategory(
                categoryId: widget.categoryId!,
                name: _nameController.text,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                color: _colorToHex(_selectedColor),
                isActive: _isActive,
              ),
            );
      } else {
        context.read<CategoryBloc>().add(
              CreateCategory(
                name: _nameController.text,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                color: _colorToHex(_selectedColor),
              ),
            );
      }

      // Listen for success
      context.read<CategoryBloc>().stream.listen((state) {
        if (state is CategoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }).cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isEditMode = widget.categoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? (loc?.translate('editCategory') ?? 'Edit Category') : (loc?.translate('addCategory') ?? 'Add Category')),
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
              // Name
              AppTextField(
                controller: _nameController,
                label: loc?.translate('name') ?? 'Category Name',
                prefixIcon: Icons.category,
                validator: (v) => Validators.required(v, loc?.translate('name') ?? 'Category Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Category Note (Optional)
              AppTextField(
                controller: _categoryNoteController,
                label: loc?.translate('categoryNote') ?? 'Category Note (Optional)',
                hint: loc?.translate('enterCategoryNote') ?? 'Enter category note here...',
                maxLines: 3,
                prefixIcon: Icons.note_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Sorting
              AppTextField(
                controller: _sortingController,
                label: loc?.translate('sorting') ?? 'Sorting',
                hint: loc?.translate('addSortingId') ?? 'Add Sorting ID',
                prefixIcon: Icons.sort,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Percentage Discount (Optional)
              AppTextField(
                controller: _percentageDiscountController,
                label: loc?.translate('percentageDiscount') ?? 'Percentage Discount',
                hint: loc?.translate('addPercentageDiscount') ?? 'Add Percentage Discount (Optional)',
                prefixIcon: Icons.discount,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: loc?.translate('description') ?? 'Description',
                hint: 'Description...',
                maxLines: 5,
                prefixIcon: Icons.description_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Short Description
              AppTextField(
                controller: _shortDescriptionController,
                label: loc?.translate('shortDescription') ?? 'Short Description',
                hint: 'Description...',
                prefixIcon: Icons.short_text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Color picker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Color',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _predefinedColors.map((color) {
                          final isSelected = color == _selectedColor;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                                _colorController.text = _colorToHex(color);
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image upload
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
                  child: _categoryImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            _categoryImage!,
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

              // Active toggle
              SwitchListTile(
                title: Text(loc?.translate('active') ?? 'Active?'),
                subtitle: Text(
                  loc?.translate('activeCategoryDescription') ?? 'By setting the category to "Active," this category will be visible in the list; otherwise, it will remain hidden.',
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),

              // Is Open All Day toggle
              SwitchListTile(
                title: Text(loc?.translate('isOpenAllDay') ?? 'Is Open All Day'),
                value: _isOpenAllDay,
                onChanged: (value) {
                  setState(() {
                    _isOpenAllDay = value;
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


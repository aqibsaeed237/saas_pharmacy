import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/customer.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../bloc/customer_bloc.dart';

/// Customer form screen (Add/Edit)
class CustomerFormScreen extends StatefulWidget {
  final String? customerId;

  const CustomerFormScreen({super.key, this.customerId});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadCustomerData();
    }
  }

  void _loadCustomerData() {
    // Mock data - in production, load from BLoC
    setState(() {
      _nameController.text = 'John Doe';
      _emailController.text = 'john@example.com';
      _phoneController.text = '+1234567890';
      _addressController.text = '123 Main St';
      _cityController.text = 'New York';
      _countryController.text = 'USA';
      _dateOfBirth = DateTime(1990, 1, 1);
      _selectedGender = 'Male';
      _notesController.text = 'Regular customer';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final loc = AppLocalizations.of(context);
      final customer = Customer(
        id: widget.customerId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        city: _cityController.text.isEmpty ? null : _cityController.text,
        country: _countryController.text.isEmpty ? null : _countryController.text,
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        tenantId: 'tenant1', // Mock tenant ID
        isActive: true,
        createdAt: widget.customerId != null
            ? DateTime.now().subtract(const Duration(days: 30))
            : DateTime.now(),
        updatedAt: widget.customerId != null ? DateTime.now() : null,
      );

      if (widget.customerId != null) {
        context.read<CustomerBloc>().add(UpdateCustomer(customer));
      } else {
        context.read<CustomerBloc>().add(AddCustomer(customer));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customerId != null
              ? loc?.translate('editCustomer') ?? 'Edit Customer'
              : loc?.translate('addCustomer') ?? 'Add Customer',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: loc?.translate('name') ?? 'Name',
                  prefixIcon: Icons.person,
                  validator: (v) => Validators.required(v, loc?.translate('name') ?? 'Name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: loc?.translate('email') ?? 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  label: loc?.translate('phone') ?? 'Phone',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _addressController,
                  label: loc?.translate('address') ?? 'Address',
                  prefixIcon: Icons.location_on,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _cityController,
                        label: loc?.translate('city') ?? 'City',
                        prefixIcon: Icons.location_city,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _countryController,
                        label: loc?.translate('country') ?? 'Country',
                        prefixIcon: Icons.public,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Date of Birth
                InkWell(
                  onTap: _selectDateOfBirth,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: loc?.translate('dateOfBirth') ?? 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    child: Text(
                      _dateOfBirth != null
                          ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
                          : loc?.translate('selectDate') ?? 'Select Date',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: loc?.translate('gender') ?? 'Gender',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _notesController,
                  label: loc?.translate('notes') ?? 'Notes',
                  maxLines: 3,
                  prefixIcon: Icons.note_outlined,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: loc?.translate('save') ?? 'Save',
                  onPressed: _handleSave,
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


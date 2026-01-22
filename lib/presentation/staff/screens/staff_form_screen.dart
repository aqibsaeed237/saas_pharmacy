import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/validators.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Staff form screen (Add/Edit)
class StaffFormScreen extends StatefulWidget {
  final String? staffId;

  const StaffFormScreen({super.key, this.staffId});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.cashier;
  bool _obscurePassword = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.staffId != null;
    if (_isEditMode) {
      // Load staff data - mock for now
      _loadStaffData();
    }
  }

  void _loadStaffData() {
    // Mock data loading
    _firstNameController.text = 'John';
    _lastNameController.text = 'Doe';
    _emailController.text = 'john@example.com';
    _phoneController.text = '+1234567890';
    _selectedRole = UserRole.manager;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Save staff - will be handled by BLoC
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Staff updated successfully' : 'Staff added successfully'),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Staff' : 'Add Staff'),
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
              // First Name
              AppTextField(
                controller: _firstNameController,
                label: 'First Name',
                prefixIcon: Icons.person_outlined,
                validator: (v) => Validators.required(v, 'First Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Last Name
              AppTextField(
                controller: _lastNameController,
                label: 'Last Name',
                prefixIcon: Icons.person_outlined,
                validator: (v) => Validators.required(v, 'Last Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Email
              AppTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.email,
                enabled: !_isEditMode, // Email cannot be changed in edit mode
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Phone
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Password (only for new staff)
              if (!_isEditMode) ...[
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
              ],

              // Role
              Builder(
                builder: (context) {
                  final loc = AppLocalizations.of(context);
                  return DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: loc?.translate('role') ?? 'Role',
                      prefixIcon: const Icon(Icons.work_outline),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // Save button
              AppButton(
                label: _isEditMode ? 'Update Staff' : 'Add Staff',
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


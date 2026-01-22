import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import '../../../core/constants/app_strings.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/theme_manager.dart';
import '../../../core/utils/locale_manager.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/di/injection_container.dart';

/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();
  late final ThemeManager _themeManager;
  late final LocaleManager _localeManager;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Default';

  @override
  void initState() {
    super.initState();
    _themeManager = getIt<ThemeManager>();
    _localeManager = getIt<LocaleManager>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load current theme mode from manager
    await _themeManager.loadTheme();
    await _localeManager.loadLocale();
    
    // Set UI state based on loaded settings
    setState(() {
      _selectedLanguage = _localeManager.locale.languageCode == 'ur' ? 'Urdu' : 'English';
      _selectedTheme = _themeManager.vendorTheme == 'pharmacy_blue' 
          ? 'Pharmacy Blue'
          : _themeManager.vendorTheme == 'medical_green'
              ? 'Medical Green'
              : 'Default';
    });
  }

  Future<void> _pickImage() async {
    final loc = AppLocalizations.of(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc?.translate('profileImageUpdated') ?? 'Profile image updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    final loc = AppLocalizations.of(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc?.translate('profileImageUpdated') ?? 'Profile image updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showImagePicker() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
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
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  loc?.translate('removePhoto') ?? 'Remove Photo',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc?.translate('profileImageRemoved') ?? 'Profile image removed')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _themeManager.setThemeMode(
      value ? ThemeMode.dark : ThemeMode.light,
    );
    if (mounted) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? (loc?.translate('darkModeEnabled') ?? 'Dark mode enabled')
                : (loc?.translate('lightModeEnabled') ?? 'Light mode enabled'),
          ),
        ),
      );
    }
  }

  Future<void> _changeLanguage(String language) async {
    final locale = language == 'Urdu' ? const Locale('ur', '') : const Locale('en', '');
    await _localeManager.setLocale(locale);
    setState(() {
      _selectedLanguage = language;
    });
    if (mounted) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (loc?.translate('languageChanged') ?? 'Language changed to {language}. Changes applied instantly.')
                .replaceAll('{language}', language),
          ),
        ),
      );
    }
    // Locale change will trigger rebuild via listener in main.dart
  }

  Future<void> _changeTheme(String theme) async {
    String themeKey = 'default';
    if (theme == 'Pharmacy Blue') themeKey = 'pharmacy_blue';
    if (theme == 'Medical Green') themeKey = 'medical_green';
    
    await _themeManager.setVendorTheme(themeKey);
    setState(() {
      _selectedTheme = theme;
    });
    if (mounted) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (loc?.translate('themeChanged') ?? 'Theme changed to {theme}').replaceAll('{theme}', theme),
          ),
        ),
      );
    }
    // Note: In a real app, you'd need to rebuild the MaterialApp with new theme
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('settings') ?? 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          // Profile section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: theme.colorScheme.onPrimaryContainer,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('john.doe@example.com'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.pushNamed('profileEdit');
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(loc?.translate('editProfile') ?? 'Edit Profile'),
                  ),
                ],
              ),
            ),
          ),

          // Appearance
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ExpansionTile(
              leading: const Icon(Icons.palette),
              title: Text(loc?.translate('appearance') ?? 'Appearance'),
              children: [
                SwitchListTile(
                  title: Text(loc?.translate('darkMode') ?? 'Dark Mode'),
                  value: isDark,
                  onChanged: _toggleDarkMode,
                ),
                const Divider(),
                ListTile(
                  title: Text(loc?.translate('theme') ?? 'Theme'),
                  subtitle: Text(_selectedTheme),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(loc?.translate('selectTheme') ?? 'Select Theme'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String>(
                              title: Text(loc?.translate('defaultTheme') ?? 'Default'),
                              value: 'Default',
                              groupValue: _selectedTheme,
                              onChanged: (value) {
                                Navigator.pop(context);
                                _changeTheme(value!);
                              },
                            ),
                            RadioListTile<String>(
                              title: Text(loc?.translate('pharmacyBlue') ?? 'Pharmacy Blue'),
                              value: 'Pharmacy Blue',
                              groupValue: _selectedTheme,
                              onChanged: (value) {
                                Navigator.pop(context);
                                _changeTheme(value!);
                              },
                            ),
                            RadioListTile<String>(
                              title: Text(loc?.translate('medicalGreen') ?? 'Medical Green'),
                              value: 'Medical Green',
                              groupValue: _selectedTheme,
                              onChanged: (value) {
                                Navigator.pop(context);
                                _changeTheme(value!);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Language
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(loc?.translate('language') ?? 'Language'),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(loc?.translate('selectLanguage') ?? 'Select Language'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: Text(loc?.translate('english') ?? 'English'),
                          value: 'English',
                          groupValue: _selectedLanguage,
                          onChanged: (value) {
                            Navigator.pop(context);
                            _changeLanguage(value!);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(loc?.translate('urdu') ?? 'اردو (Urdu)'),
                          value: 'Urdu',
                          groupValue: _selectedLanguage,
                          onChanged: (value) {
                            Navigator.pop(context);
                            _changeLanguage(value!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Wallet
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text(loc?.translate('wallet') ?? 'Wallet'),
              subtitle: Text(loc?.translate('manageWallet') ?? 'Manage your wallet'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushNamed('wallet');
              },
            ),
          ),

          // Subscription
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.card_membership),
              title: Text(loc?.translate('subscriptions') ?? 'Subscriptions'),
              subtitle: Text(loc?.translate('manageSubscription') ?? 'Manage your subscription'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushNamed('subscriptions');
              },
            ),
          ),

          // Payment Methods
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.payment),
              title: Text(loc?.translate('paymentMethods') ?? 'Payment Methods'),
              subtitle: Text(loc?.translate('managePaymentMethods') ?? 'Manage payment methods'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushNamed('paymentMethods');
              },
            ),
          ),

          // Notifications
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ExpansionTile(
              leading: const Icon(Icons.notifications),
              title: Text(loc?.translate('notifications') ?? 'Notifications'),
              children: [
                SwitchListTile(
                  title: Text(loc?.translate('lowStockAlerts') ?? 'Low Stock Alerts'),
                  value: true,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? (loc?.translate('lowStockAlertsEnabled') ?? 'Low stock alerts enabled')
                              : (loc?.translate('lowStockAlertsDisabled') ?? 'Low stock alerts disabled'),
                        ),
                      ),
                    );
                  },
                ),
                SwitchListTile(
                  title: Text(loc?.translate('expiryAlerts') ?? 'Expiry Alerts'),
                  value: true,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? (loc?.translate('expiryAlertsEnabled') ?? 'Expiry alerts enabled')
                              : (loc?.translate('expiryAlertsDisabled') ?? 'Expiry alerts disabled'),
                        ),
                      ),
                    );
                  },
                ),
                SwitchListTile(
                  title: Text(loc?.translate('systemNotifications') ?? 'System Notifications'),
                  value: true,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? (loc?.translate('systemNotificationsEnabled') ?? 'System notifications enabled')
                              : (loc?.translate('systemNotificationsDisabled') ?? 'System notifications disabled'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // About
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              leading: const Icon(Icons.info),
              title: Text(loc?.translate('about') ?? 'About'),
              children: [
                ListTile(
                  title: Text(loc?.translate('version') ?? 'Version'),
                  subtitle: Text(loc?.translate('version') ?? '1.0.0'),
                ),
                ListTile(
                  title: Text(loc?.translate('termsOfService') ?? 'Terms of Service'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc?.translate('termsOfService') ?? 'Terms of Service')),
                    );
                  },
                ),
                ListTile(
                  title: Text(loc?.translate('privacyPolicy') ?? 'Privacy Policy'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc?.translate('privacyPolicy') ?? 'Privacy Policy')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                loc?.translate('logout') ?? 'Logout',
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(loc?.translate('logout') ?? 'Logout'),
                    content: Text(loc?.translate('areYouSureLogout') ?? 'Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc?.translate('cancel') ?? 'Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/login');
                        },
                        child: Text(loc?.translate('logout') ?? 'Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

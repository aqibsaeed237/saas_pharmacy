import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';

/// Theme manager for handling theme changes
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  String _vendorTheme = 'default';

  ThemeMode get themeMode => _themeMode;
  String get vendorTheme => _vendorTheme;

  ThemeManager() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _vendorTheme = prefs.getString('vendor_theme') ?? 'default';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setVendorTheme(String theme) async {
    _vendorTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendor_theme', theme);
    notifyListeners();
  }

  ThemeData getCurrentTheme(BuildContext context) {
    final brightness = _themeMode == ThemeMode.system
        ? MediaQuery.of(context).platformBrightness
        : (_themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);

    switch (_vendorTheme) {
      case 'pharmacy_blue':
        return brightness == Brightness.dark
            ? AppTheme.pharmacyBlueDarkTheme
            : AppTheme.pharmacyBlueLightTheme;
      case 'medical_green':
        return brightness == Brightness.dark
            ? AppTheme.medicalGreenDarkTheme
            : AppTheme.medicalGreenLightTheme;
      default:
        return brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
    }
  }
}


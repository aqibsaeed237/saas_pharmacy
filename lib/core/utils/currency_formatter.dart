import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

/// Currency formatting utilities
class CurrencyFormatter {
  /// Format amount as currency using app currency settings
  static String format(double amount, {String? symbol, int? decimalDigits, String? position}) {
    final useSymbol = symbol ?? AppCurrency.symbol;
    final useDecimalDigits = decimalDigits ?? AppCurrency.decimalDigits;
    final usePosition = position ?? AppCurrency.position;
    
    // Format the number with proper decimal places
    final numberFormat = NumberFormat('#,##0.${'0' * useDecimalDigits}');
    final formattedNumber = numberFormat.format(amount);
    
    // Add currency symbol based on position
    if (usePosition == 'before') {
      return '$useSymbol $formattedNumber';
    } else {
      return '$formattedNumber $useSymbol';
    }
  }

  /// Format amount with custom symbol override
  static String formatWithSymbol(double amount, String customSymbol) {
    return format(amount, symbol: customSymbol);
  }

  /// Parse currency string to double
  static double? parse(String? currencyString) {
    if (currencyString == null || currencyString.isEmpty) return null;
    
    // Remove currency symbols and spaces
    final cleaned = currencyString
        .replaceAll(RegExp(r'[^\d.-]'), '')
        .trim();
    
    return double.tryParse(cleaned);
  }

  /// Get currency symbol
  static String get symbol => AppCurrency.symbol;
  
  /// Get currency code
  static String get code => AppCurrency.code;
  
  /// Get formatted currency display (e.g., "Rs 1,000.00" or "1,000.00 Rs")
  static String formatDisplay(double amount) {
    return format(amount);
  }
}

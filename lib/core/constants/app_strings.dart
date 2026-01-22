/// Application-wide string constants
class AppStrings {
  // App Info
  static const String appName = 'Pharmacy POS';
  static const String appTagline = 'Professional Pharmacy Management';
  
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String clear = 'Clear';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String close = 'Close';
  
  // Authentication
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String register = 'Register';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  
  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String sales = 'Sales';
  static const String inventory = 'Inventory';
  static const String products = 'Products';
  static const String purchases = 'Purchases';
  static const String reports = 'Reports';
  static const String staff = 'Staff';
  static const String notifications = 'Notifications';
  static const String settings = 'Settings';
  static const String subscriptions = 'Subscriptions';
  
  // Errors
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Session expired. Please login again.';
  static const String notFoundError = 'Resource not found.';
  static const String unknownError = 'An unknown error occurred.';
  
  // Validation
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 8 characters';
  
  // Empty States
  static const String noData = 'No data available';
  static const String noProducts = 'No products found';
  static const String noSales = 'No sales found';
  static const String noStaff = 'No staff members found';
}

/// Application-wide currency constants
class AppCurrency {
  // Default currency settings
  static String symbol = 'Rs';
  static String code = 'PKR';
  static String name = 'Pakistani Rupee';
  static int decimalDigits = 2;
  static String thousandSeparator = ',';
  static String decimalSeparator = '.';
  
  // Currency position: 'before' or 'after'
  static String position = 'before';
  
  /// Get formatted currency symbol with space
  static String get formattedSymbol {
    return position == 'before' ? '$symbol ' : ' $symbol';
  }
  
  /// Change currency settings
  static void setCurrency({
    String? newSymbol,
    String? newCode,
    String? newName,
    int? newDecimalDigits,
    String? newThousandSeparator,
    String? newDecimalSeparator,
    String? newPosition,
  }) {
    if (newSymbol != null) symbol = newSymbol;
    if (newCode != null) code = newCode;
    if (newName != null) name = newName;
    if (newDecimalDigits != null) decimalDigits = newDecimalDigits;
    if (newThousandSeparator != null) thousandSeparator = newThousandSeparator;
    if (newDecimalSeparator != null) decimalSeparator = newDecimalSeparator;
    if (newPosition != null) position = newPosition;
  }
  
  /// Reset to default (PKR)
  static void resetToDefault() {
    symbol = 'Rs';
    code = 'PKR';
    name = 'Pakistani Rupee';
    decimalDigits = 2;
    thousandSeparator = ',';
    decimalSeparator = '.';
    position = 'before';
  }
}


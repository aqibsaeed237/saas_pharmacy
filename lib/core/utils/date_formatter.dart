import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayDateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// Format date to API format (yyyy-MM-dd)
  static String toApiDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format datetime to API format (yyyy-MM-dd HH:mm:ss)
  static String toApiDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Format date for display (MMM dd, yyyy)
  static String toDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  /// Format datetime for display (MMM dd, yyyy HH:mm)
  static String toDisplayDateTime(DateTime dateTime) {
    return _displayDateTimeFormat.format(dateTime);
  }

  /// Format time only (HH:mm)
  static String toTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Parse API date string to DateTime
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse API datetime string to DateTime
  static DateTime? parseApiDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return _dateTimeFormat.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
}


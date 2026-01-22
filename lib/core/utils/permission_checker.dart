import '../../domain/entities/user.dart';
import '../constants/app_enums.dart';

/// Permission checking utilities
class PermissionChecker {
  /// Check if user has admin role
  static bool isAdmin(User user) {
    return user.role == UserRole.admin;
  }

  /// Check if user has manager role or higher
  static bool isManagerOrAbove(User user) {
    return user.role == UserRole.admin || user.role == UserRole.manager;
  }

  /// Check if user can manage staff
  static bool canManageStaff(User user) {
    return user.role == UserRole.admin || user.role == UserRole.manager;
  }

  /// Check if user can view reports
  static bool canViewReports(User user) {
    return user.role == UserRole.admin || user.role == UserRole.manager;
  }

  /// Check if user can manage inventory
  static bool canManageInventory(User user) {
    return user.role == UserRole.admin || user.role == UserRole.manager;
  }

  /// Check if user can process sales
  static bool canProcessSales(User user) {
    return true; // All roles can process sales
  }

  /// Check if user can manage purchases
  static bool canManagePurchases(User user) {
    return user.role == UserRole.admin || user.role == UserRole.manager;
  }

  /// Check if user can manage subscriptions
  static bool canManageSubscriptions(User user) {
    return user.role == UserRole.admin;
  }
}


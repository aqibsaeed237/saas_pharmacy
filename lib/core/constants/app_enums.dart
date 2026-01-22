/// Application-wide enums
enum UserRole {
  admin,
  manager,
  cashier;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.cashier:
        return 'Cashier';
    }
  }
}

enum TransactionType {
  sale,
  purchase,
  return_,
  adjustment;

  String get displayName {
    switch (this) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.return_:
        return 'Return';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }
}

enum PaymentMethod {
  cash,
  card,
  mobileMoney,
  bankTransfer;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  trial;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.trial:
        return 'Trial';
    }
  }
}

enum NotificationType {
  lowStock,
  expiry,
  subscription,
  system;

  String get displayName {
    switch (this) {
      case NotificationType.lowStock:
        return 'Low Stock';
      case NotificationType.expiry:
        return 'Expiry Alert';
      case NotificationType.subscription:
        return 'Subscription';
      case NotificationType.system:
        return 'System';
    }
  }
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
  expired;

  String get displayName {
    switch (this) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.expired:
        return 'Expired';
    }
  }
}


import 'package:equatable/equatable.dart';

/// Expense entity
class Expense extends Equatable {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final String category; // e.g., 'Rent', 'Utilities', 'Salaries', 'Marketing'
  final DateTime date;
  final String? receiptUrl;
  final String? paidTo; // Supplier/Vendor name
  final String paymentMethod; // 'Cash', 'Card', 'Bank Transfer'
  final String tenantId;
  final String? createdBy; // Staff ID
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.receiptUrl,
    this.paidTo,
    required this.paymentMethod,
    required this.tenantId,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  Expense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    String? receiptUrl,
    String? paidTo,
    String? paymentMethod,
    String? tenantId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paidTo: paidTo ?? this.paidTo,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      tenantId: tenantId ?? this.tenantId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        amount,
        category,
        date,
        receiptUrl,
        paidTo,
        paymentMethod,
        tenantId,
        createdBy,
        createdAt,
        updatedAt,
      ];
}


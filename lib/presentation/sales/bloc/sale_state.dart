import 'package:equatable/equatable.dart';
import '../../../domain/entities/sale.dart';
import '../../../core/constants/app_enums.dart';

/// Sale states
abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SaleInitial extends SaleState {
  const SaleInitial();
}

/// Cart state
class SaleCartState extends SaleState {
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final PaymentMethod paymentMethod;

  const SaleCartState({
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.total,
    this.paymentMethod = PaymentMethod.cash,
  });

  SaleCartState copyWith({
    List<SaleItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    PaymentMethod? paymentMethod,
  }) {
    return SaleCartState(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  List<Object> get props => [items, subtotal, discount, tax, total, paymentMethod];
}

/// Processing sale state
class SaleProcessing extends SaleState {
  const SaleProcessing();
}

/// Sale success state
class SaleSuccess extends SaleState {
  final Sale sale;

  const SaleSuccess(this.sale);

  @override
  List<Object> get props => [sale];
}

/// Sale error state
class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object> get props => [message];
}


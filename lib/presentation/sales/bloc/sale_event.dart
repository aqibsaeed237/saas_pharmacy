import 'package:equatable/equatable.dart';
import '../../../core/constants/app_enums.dart';
import '../../../domain/entities/sale.dart';

/// Sale events
abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

/// Add item to cart event
class AddItemToCart extends SaleEvent {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  const AddItemToCart({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });

  @override
  List<Object> get props => [productId, productName, price, quantity];
}

/// Remove item from cart event
class RemoveItemFromCart extends SaleEvent {
  final String itemId;

  const RemoveItemFromCart(this.itemId);

  @override
  List<Object> get props => [itemId];
}

/// Update item quantity event
class UpdateItemQuantity extends SaleEvent {
  final String itemId;
  final int quantity;

  const UpdateItemQuantity({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object> get props => [itemId, quantity];
}

/// Apply discount event
class ApplyDiscount extends SaleEvent {
  final double discount;

  const ApplyDiscount(this.discount);

  @override
  List<Object> get props => [discount];
}

/// Set payment method event
class SetPaymentMethod extends SaleEvent {
  final PaymentMethod paymentMethod;

  const SetPaymentMethod(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

/// Process sale event
class ProcessSale extends SaleEvent {
  const ProcessSale();
}

/// Clear cart event
class ClearCart extends SaleEvent {
  const ClearCart();
}


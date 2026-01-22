part of 'payment_method_bloc.dart';

/// Payment Method events
abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentMethods extends PaymentMethodEvent {
  final String? customerId;

  const LoadPaymentMethods({this.customerId});

  @override
  List<Object?> get props => [customerId];
}

class AddPaymentMethod extends PaymentMethodEvent {
  final String? customerId;
  final entity.PaymentMethodEntityType type;
  final String name;
  final String? cardNumber;
  final String? cardHolderName;
  final String? bankName;
  final String? accountNumber;
  final bool isDefault;

  const AddPaymentMethod({
    this.customerId,
    required this.type,
    required this.name,
    this.cardNumber,
    this.cardHolderName,
    this.bankName,
    this.accountNumber,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
        customerId,
        type,
        name,
        cardNumber,
        cardHolderName,
        bankName,
        accountNumber,
        isDefault,
      ];
}

class UpdatePaymentMethod extends PaymentMethodEvent {
  final String id;
  final String name;
  final String? cardNumber;
  final String? cardHolderName;
  final String? bankName;
  final String? accountNumber;
  final bool isDefault;

  const UpdatePaymentMethod({
    required this.id,
    required this.name,
    this.cardNumber,
    this.cardHolderName,
    this.bankName,
    this.accountNumber,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        cardNumber,
        cardHolderName,
        bankName,
        accountNumber,
        isDefault,
      ];
}

class DeletePaymentMethod extends PaymentMethodEvent {
  final String id;

  const DeletePaymentMethod(this.id);

  @override
  List<Object?> get props => [id];
}

class SetDefaultPaymentMethod extends PaymentMethodEvent {
  final String id;

  const SetDefaultPaymentMethod(this.id);

  @override
  List<Object?> get props => [id];
}


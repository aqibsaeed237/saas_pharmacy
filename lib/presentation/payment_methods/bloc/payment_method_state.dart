part of 'payment_method_bloc.dart';

/// Payment Method states
abstract class PaymentMethodState extends Equatable {
  const PaymentMethodState();

  @override
  List<Object?> get props => [];
}

class PaymentMethodInitial extends PaymentMethodState {}

class PaymentMethodLoading extends PaymentMethodState {}

class PaymentMethodsLoaded extends PaymentMethodState {
  final List<entity.PaymentMethodEntity> paymentMethods;

  const PaymentMethodsLoaded({required this.paymentMethods});

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentMethodAdded extends PaymentMethodState {}

class PaymentMethodUpdated extends PaymentMethodState {}

class PaymentMethodDeleted extends PaymentMethodState {}

class PaymentMethodError extends PaymentMethodState {
  final String message;

  const PaymentMethodError(this.message);

  @override
  List<Object?> get props => [message];
}


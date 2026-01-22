part of 'customer_bloc.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomersLoaded extends CustomerState {
  final List<Customer> customers;

  const CustomersLoaded({required this.customers});

  @override
  List<Object?> get props => [customers];
}

class CustomerHistoryLoaded extends CustomerState {
  final List<Map<String, dynamic>> history;

  const CustomerHistoryLoaded({required this.history});

  @override
  List<Object?> get props => [history];
}

class CustomerSuccess extends CustomerState {
  final String message;

  const CustomerSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}


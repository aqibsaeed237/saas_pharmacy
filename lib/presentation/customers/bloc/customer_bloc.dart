import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/customer.dart';

part 'customer_event.dart';
part 'customer_state.dart';

/// Customer BLoC
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerBloc() : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<LoadCustomerHistory>(_onLoadCustomerHistory);
  }

  // Mock customers data
  final List<Customer> _mockCustomers = [
    Customer(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+1234567890',
      address: '123 Main St',
      city: 'New York',
      country: 'USA',
      dateOfBirth: DateTime(1990, 1, 1),
      gender: 'Male',
      notes: 'Regular customer',
      tenantId: 'tenant1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Customer(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '+0987654321',
      address: '456 Oak Ave',
      city: 'Los Angeles',
      country: 'USA',
      dateOfBirth: DateTime(1985, 5, 15),
      gender: 'Female',
      notes: 'VIP customer',
      tenantId: 'tenant1',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter by search if provided
    List<Customer> filtered = _mockCustomers;
    if (event.search != null && event.search!.isNotEmpty) {
      filtered = _mockCustomers.where((customer) {
        return customer.name.toLowerCase().contains(event.search!.toLowerCase()) ||
            (customer.phone?.toLowerCase().contains(event.search!.toLowerCase()) ?? false) ||
            (customer.email?.toLowerCase().contains(event.search!.toLowerCase()) ?? false);
      }).toList();
    }
    
    emit(CustomersLoaded(customers: filtered));
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newCustomer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.customer.name,
      email: event.customer.email,
      phone: event.customer.phone,
      address: event.customer.address,
      city: event.customer.city,
      country: event.customer.country,
      dateOfBirth: event.customer.dateOfBirth,
      gender: event.customer.gender,
      notes: event.customer.notes,
      tenantId: event.customer.tenantId,
      isActive: true,
      createdAt: DateTime.now(),
    );
    
    _mockCustomers.add(newCustomer);
    emit(CustomerSuccess('Customer added successfully'));
    emit(CustomersLoaded(customers: _mockCustomers));
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockCustomers.indexWhere((c) => c.id == event.customer.id);
    if (index != -1) {
      _mockCustomers[index] = event.customer.copyWith(
        updatedAt: DateTime.now(),
      );
      emit(CustomerSuccess('Customer updated successfully'));
      emit(CustomersLoaded(customers: _mockCustomers));
    } else {
      emit(CustomerError('Customer not found'));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    
    _mockCustomers.removeWhere((c) => c.id == event.customerId);
    emit(CustomerSuccess('Customer deleted successfully'));
    emit(CustomersLoaded(customers: _mockCustomers));
  }

  Future<void> _onLoadCustomerHistory(
    LoadCustomerHistory event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock purchase history
    final history = [
      {
        'id': 'sale1',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'total': 125.50,
        'items': 3,
        'invoiceNumber': 'INV-001',
      },
      {
        'id': 'sale2',
        'date': DateTime.now().subtract(const Duration(days: 12)),
        'total': 89.25,
        'items': 2,
        'invoiceNumber': 'INV-002',
      },
      {
        'id': 'sale3',
        'date': DateTime.now().subtract(const Duration(days: 20)),
        'total': 245.00,
        'items': 5,
        'invoiceNumber': 'INV-003',
      },
    ];
    
    emit(CustomerHistoryLoaded(history: history));
  }
}


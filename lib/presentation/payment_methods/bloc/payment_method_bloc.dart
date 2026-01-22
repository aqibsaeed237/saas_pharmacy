import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment_method.dart' as entity;

part 'payment_method_event.dart';
part 'payment_method_state.dart';

/// Payment Method BLoC
class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  PaymentMethodBloc() : super(PaymentMethodInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<AddPaymentMethod>(_onAddPaymentMethod);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
    on<SetDefaultPaymentMethod>(_onSetDefaultPaymentMethod);
  }

  // Mock payment methods
  List<entity.PaymentMethodEntity> _mockPaymentMethods = [
    entity.PaymentMethodEntity(
      id: 'pm1',
      customerId: '1',
      type: entity.PaymentMethodEntityType.card,
      name: 'Visa ****1234',
      cardNumber: '1234',
      cardHolderName: 'John Doe',
      isDefault: true,
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: null,
    ),
    entity.PaymentMethodEntity(
      id: 'pm2',
      customerId: null,
      type: entity.PaymentMethodEntityType.cash,
      name: 'Cash',
      isDefault: false,
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: null,
    ),
    entity.PaymentMethodEntity(
      id: 'pm3',
      customerId: null,
      type: entity.PaymentMethodEntityType.bankTransfer,
      name: 'Bank Transfer',
      bankName: 'ABC Bank',
      isDefault: false,
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: null,
    ),
  ];

  void _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    final methods = event.customerId != null
        ? _mockPaymentMethods
            .where((pm) => pm.customerId == event.customerId || pm.customerId == null)
            .toList()
        : _mockPaymentMethods.where((pm) => pm.customerId == null).toList();
    
    emit(PaymentMethodsLoaded(paymentMethods: methods));
  }

  void _onAddPaymentMethod(
    AddPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newMethod = entity.PaymentMethodEntity(
      id: 'pm${DateTime.now().millisecondsSinceEpoch}',
      customerId: event.customerId,
      type: event.type,
      name: event.name,
      cardNumber: event.cardNumber,
      cardHolderName: event.cardHolderName,
      bankName: event.bankName,
      accountNumber: event.accountNumber,
      isDefault: event.isDefault,
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    
    if (event.isDefault) {
      // Remove default from other methods
      _mockPaymentMethods = _mockPaymentMethods.map((pm) {
        if (pm.customerId == event.customerId || pm.customerId == null) {
          return pm.copyWith(isDefault: false);
        }
        return pm;
      }).toList();
    }
    
    _mockPaymentMethods.add(newMethod);
    emit(PaymentMethodAdded());
    add(LoadPaymentMethods(customerId: event.customerId));
  }

  void _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockPaymentMethods.indexWhere((pm) => pm.id == event.id);
    if (index != -1) {
      _mockPaymentMethods[index] = _mockPaymentMethods[index].copyWith(
        name: event.name,
        cardNumber: event.cardNumber,
        cardHolderName: event.cardHolderName,
        bankName: event.bankName,
        accountNumber: event.accountNumber,
        isDefault: event.isDefault,
        updatedAt: DateTime.now(),
      );
      
      if (event.isDefault) {
        // Remove default from other methods
        _mockPaymentMethods = _mockPaymentMethods.map((pm) {
          if (pm.id != event.id &&
              (pm.customerId == _mockPaymentMethods[index].customerId ||
                  pm.customerId == null)) {
            return pm.copyWith(isDefault: false);
          }
          return pm;
        }).toList();
      }
      
      emit(PaymentMethodUpdated());
      add(LoadPaymentMethods(customerId: _mockPaymentMethods[index].customerId));
    }
  }

  void _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    _mockPaymentMethods.removeWhere((pm) => pm.id == event.id);
    emit(PaymentMethodDeleted());
    add(LoadPaymentMethods());
  }

  void _onSetDefaultPaymentMethod(
    SetDefaultPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockPaymentMethods.indexWhere((pm) => pm.id == event.id);
    if (index != -1) {
      final method = _mockPaymentMethods[index];
      
      // Remove default from other methods
      _mockPaymentMethods = _mockPaymentMethods.map((pm) {
        if (pm.id == event.id) {
          return pm.copyWith(isDefault: true, updatedAt: DateTime.now());
        } else if (pm.customerId == method.customerId || pm.customerId == null) {
          return pm.copyWith(isDefault: false);
        }
        return pm;
      }).toList();
      
      emit(PaymentMethodUpdated());
      add(LoadPaymentMethods(customerId: method.customerId));
    }
  }
}


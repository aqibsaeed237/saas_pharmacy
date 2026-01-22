import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/sale.dart';
import '../../../domain/usecases/sales/create_sale_usecase.dart';
import '../../../core/constants/app_enums.dart';
import 'sale_event.dart';
import 'sale_state.dart';

/// Sale BLoC
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final CreateSaleUseCase createSaleUseCase;
  final Uuid _uuid = const Uuid();

  SaleBloc({
    required this.createSaleUseCase,
  }) : super(const SaleCartState(
          items: [],
          subtotal: 0.0,
          total: 0.0,
        )) {
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ApplyDiscount>(_onApplyDiscount);
    on<SetPaymentMethod>(_onSetPaymentMethod);
    on<ProcessSale>(_onProcessSale);
    on<ClearCart>(_onClearCart);
  }

  void _onAddItemToCart(
    AddItemToCart event,
    Emitter<SaleState> emit,
  ) {
    if (state is SaleCartState) {
      final currentState = state as SaleCartState;
      final existingItemIndex = currentState.items.indexWhere(
        (item) => item.productId == event.productId,
      );

      List<SaleItem> newItems;
      if (existingItemIndex >= 0) {
        // Update existing item quantity
        final existingItem = currentState.items[existingItemIndex];
        newItems = List.from(currentState.items);
        newItems[existingItemIndex] = SaleItem(
          id: existingItem.id,
          productId: existingItem.productId,
          productName: existingItem.productName,
          quantity: existingItem.quantity + event.quantity,
          unitPrice: existingItem.unitPrice,
          discount: existingItem.discount,
          total: (existingItem.unitPrice * (existingItem.quantity + event.quantity)) - existingItem.discount,
        );
      } else {
        // Add new item
        final itemTotal = (event.price * event.quantity);
        newItems = [
          ...currentState.items,
          SaleItem(
            id: _uuid.v4(),
            productId: event.productId,
            productName: event.productName,
            quantity: event.quantity,
            unitPrice: event.price,
            discount: 0.0,
            total: itemTotal,
          ),
        ];
      }

      final newSubtotal = _calculateSubtotal(newItems);
      final newTotal = _calculateTotal(newSubtotal, currentState.discount, currentState.tax);

      emit(currentState.copyWith(
        items: newItems,
        subtotal: newSubtotal,
        total: newTotal,
      ));
    }
  }

  void _onRemoveItemFromCart(
    RemoveItemFromCart event,
    Emitter<SaleState> emit,
  ) {
    if (state is SaleCartState) {
      final currentState = state as SaleCartState;
      final newItems = currentState.items.where((item) => item.id != event.itemId).toList();
      final newSubtotal = _calculateSubtotal(newItems);
      final newTotal = _calculateTotal(newSubtotal, currentState.discount, currentState.tax);

      emit(currentState.copyWith(
        items: newItems,
        subtotal: newSubtotal,
        total: newTotal,
      ));
    }
  }

  void _onUpdateItemQuantity(
    UpdateItemQuantity event,
    Emitter<SaleState> emit,
  ) {
    if (state is SaleCartState) {
      final currentState = state as SaleCartState;
      final newItems = currentState.items.map((item) {
        if (item.id == event.itemId) {
          return SaleItem(
            id: item.id,
            productId: item.productId,
            productName: item.productName,
            quantity: event.quantity,
            unitPrice: item.unitPrice,
            discount: item.discount,
            total: (item.unitPrice * event.quantity) - item.discount,
          );
        }
        return item;
      }).toList();

      final newSubtotal = _calculateSubtotal(newItems);
      final newTotal = _calculateTotal(newSubtotal, currentState.discount, currentState.tax);

      emit(currentState.copyWith(
        items: newItems,
        subtotal: newSubtotal,
        total: newTotal,
      ));
    }
  }

  void _onApplyDiscount(
    ApplyDiscount event,
    Emitter<SaleState> emit,
  ) {
    if (state is SaleCartState) {
      final currentState = state as SaleCartState;
      final newTotal = _calculateTotal(currentState.subtotal, event.discount, currentState.tax);

      emit(currentState.copyWith(
        discount: event.discount,
        total: newTotal,
      ));
    }
  }

  void _onSetPaymentMethod(
    SetPaymentMethod event,
    Emitter<SaleState> emit,
  ) {
    if (state is SaleCartState) {
      final currentState = state as SaleCartState;
      emit(currentState.copyWith(paymentMethod: event.paymentMethod));
    }
  }

  Future<void> _onProcessSale(
    ProcessSale event,
    Emitter<SaleState> emit,
  ) async {
    if (state is SaleCartState) {
      final currentState = state as SaleCartState;
      
      if (currentState.items.isEmpty) {
        emit(const SaleError('Cart is empty'));
        return;
      }

      emit(const SaleProcessing());

      // Generate invoice number (in real app, this would come from API)
      final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

      final sale = Sale(
        id: _uuid.v4(),
        invoiceNumber: invoiceNumber,
        items: currentState.items,
        subtotal: currentState.subtotal,
        discount: currentState.discount,
        tax: currentState.tax,
        total: currentState.total,
        paymentMethod: currentState.paymentMethod,
        staffId: '', // Will be set from auth state
        tenantId: '', // Will be set from auth state
        createdAt: DateTime.now(),
      );

      final result = await createSaleUseCase(sale);

      result.fold(
        (failure) => emit(SaleError(failure.message)),
        (createdSale) {
          emit(SaleSuccess(createdSale));
          // Clear cart after successful sale
          add(const ClearCart());
        },
      );
    }
  }

  void _onClearCart(
    ClearCart event,
    Emitter<SaleState> emit,
  ) {
    emit(const SaleCartState(
      items: [],
      subtotal: 0.0,
      total: 0.0,
    ));
  }

  double _calculateSubtotal(List<SaleItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  double _calculateTotal(double subtotal, double discount, double tax) {
    return (subtotal - discount) + tax;
  }
}


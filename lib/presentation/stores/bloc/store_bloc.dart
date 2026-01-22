import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/store.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final Uuid _uuid = const Uuid();

  // Mock stores
  final List<Store> _mockStores = [
    Store(
      id: 'store1',
      name: 'Main Pharmacy',
      description: 'Main branch location',
      addressLine1: '123 Main St',
      city: 'Lahore',
      state: 'Punjab',
      postalCode: '54000',
      country: 'Pakistan',
      phone: '+92-300-1234567',
      email: 'main@pharmacy.com',
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Store(
      id: 'store2',
      name: 'Downtown Branch',
      description: 'Downtown location',
      addressLine1: '456 Market St',
      city: 'Lahore',
      state: 'Punjab',
      postalCode: '54001',
      country: 'Pakistan',
      phone: '+92-300-1234568',
      email: 'downtown@pharmacy.com',
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
  ];

  String? _currentStoreId;

  StoreBloc() : super(StoreInitial()) {
    on<LoadStores>(_onLoadStores);
    on<LoadCurrentStore>(_onLoadCurrentStore);
    on<SwitchStore>(_onSwitchStore);
    on<AddStore>(_onAddStore);
    on<UpdateStore>(_onUpdateStore);
    on<DeleteStore>(_onDeleteStore);
  }

  void _onLoadStores(
    LoadStores event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(StoresLoaded(stores: _mockStores));
  }

  void _onLoadCurrentStore(
    LoadCurrentStore event,
    Emitter<StoreState> emit,
  ) async {
    if (_currentStoreId != null) {
      final store = _mockStores.firstWhere(
        (s) => s.id == _currentStoreId,
        orElse: () => _mockStores.first,
      );
      emit(CurrentStoreLoaded(store: store));
    } else {
      emit(CurrentStoreLoaded(store: _mockStores.first));
    }
  }

  void _onSwitchStore(
    SwitchStore event,
    Emitter<StoreState> emit,
  ) async {
    _currentStoreId = event.storeId;
    final store = _mockStores.firstWhere(
      (s) => s.id == event.storeId,
      orElse: () => _mockStores.first,
    );
    emit(StoreSwitched(store: store));
    emit(CurrentStoreLoaded(store: store));
  }

  void _onAddStore(
    AddStore event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final newStore = event.store.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    _mockStores.add(newStore);

    emit(StoreAdded(store: newStore));
    emit(StoresLoaded(stores: _mockStores));
  }

  void _onUpdateStore(
    UpdateStore event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockStores.indexWhere((s) => s.id == event.store.id);
    if (index != -1) {
      _mockStores[index] = event.store.copyWith(updatedAt: DateTime.now());
    }

    emit(StoreUpdated(store: event.store));
    emit(StoresLoaded(stores: _mockStores));
  }

  void _onDeleteStore(
    DeleteStore event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    _mockStores.removeWhere((s) => s.id == event.storeId);

    emit(StoreDeleted());
    emit(StoresLoaded(stores: _mockStores));
  }
}


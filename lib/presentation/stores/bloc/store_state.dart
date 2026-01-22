part of 'store_bloc.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoresLoaded extends StoreState {
  final List<Store> stores;

  const StoresLoaded({required this.stores});

  @override
  List<Object?> get props => [stores];
}

class CurrentStoreLoaded extends StoreState {
  final Store store;

  const CurrentStoreLoaded({required this.store});

  @override
  List<Object?> get props => [store];
}

class StoreSwitched extends StoreState {
  final Store store;

  const StoreSwitched({required this.store});

  @override
  List<Object?> get props => [store];
}

class StoreAdded extends StoreState {
  final Store store;

  const StoreAdded({required this.store});

  @override
  List<Object?> get props => [store];
}

class StoreUpdated extends StoreState {
  final Store store;

  const StoreUpdated({required this.store});

  @override
  List<Object?> get props => [store];
}

class StoreDeleted extends StoreState {}

class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}


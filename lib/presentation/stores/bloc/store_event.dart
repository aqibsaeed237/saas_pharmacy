part of 'store_bloc.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object> get props => [];
}

class LoadStores extends StoreEvent {
  final String? search;

  const LoadStores({this.search});

  @override
  List<Object> get props => [search ?? ''];
}

class LoadCurrentStore extends StoreEvent {}

class SwitchStore extends StoreEvent {
  final String storeId;

  const SwitchStore(this.storeId);

  @override
  List<Object> get props => [storeId];
}

class AddStore extends StoreEvent {
  final Store store;

  const AddStore(this.store);

  @override
  List<Object> get props => [store];
}

class UpdateStore extends StoreEvent {
  final Store store;

  const UpdateStore(this.store);

  @override
  List<Object> get props => [store];
}

class DeleteStore extends StoreEvent {
  final String storeId;

  const DeleteStore(this.storeId);

  @override
  List<Object> get props => [storeId];
}


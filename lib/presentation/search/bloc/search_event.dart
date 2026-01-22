part of 'search_bloc.dart';

/// Search events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class PerformSearch extends SearchEvent {
  final String query;

  const PerformSearch(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {}


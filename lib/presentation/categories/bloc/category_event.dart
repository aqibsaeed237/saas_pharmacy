import 'package:equatable/equatable.dart';

/// Category events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load categories event
class LoadCategories extends CategoryEvent {
  final String? search;

  const LoadCategories({this.search});

  @override
  List<Object?> get props => [search];
}

/// Create category event
class CreateCategory extends CategoryEvent {
  final String name;
  final String? description;
  final String? color;

  const CreateCategory({
    required this.name,
    this.description,
    this.color,
  });

  @override
  List<Object?> get props => [name, description, color];
}

/// Update category event
class UpdateCategory extends CategoryEvent {
  final String categoryId;
  final String name;
  final String? description;
  final String? color;
  final bool isActive;

  const UpdateCategory({
    required this.categoryId,
    required this.name,
    this.description,
    this.color,
    required this.isActive,
  });

  @override
  List<Object?> get props => [categoryId, name, description, color, isActive];
}

/// Delete category event
class DeleteCategory extends CategoryEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}


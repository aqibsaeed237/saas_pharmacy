import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';

/// Category BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  // Mock categories data
  final List<Map<String, dynamic>> _mockCategories = [
    {
      'id': 'cat1',
      'name': 'Medications',
      'description': 'Prescription and over-the-counter medications',
      'color': '#2196F3',
      'isActive': true,
    },
    {
      'id': 'cat2',
      'name': 'Vitamins & Supplements',
      'description': 'Vitamins, minerals, and dietary supplements',
      'color': '#4CAF50',
      'isActive': true,
    },
    {
      'id': 'cat3',
      'name': 'Personal Care',
      'description': 'Skincare, hygiene, and personal care products',
      'color': '#FF9800',
      'isActive': true,
    },
    {
      'id': 'cat4',
      'name': 'Baby Care',
      'description': 'Baby products and infant care items',
      'color': '#E91E63',
      'isActive': true,
    },
    {
      'id': 'cat5',
      'name': 'First Aid',
      'description': 'Bandages, antiseptics, and first aid supplies',
      'color': '#F44336',
      'isActive': true,
    },
    {
      'id': 'cat6',
      'name': 'Medical Devices',
      'description': 'Blood pressure monitors, thermometers, etc.',
      'color': '#9C27B0',
      'isActive': true,
    },
  ];

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final categories = _mockCategories
        .where((cat) => event.search == null || 
            cat['name'].toString().toLowerCase().contains(event.search!.toLowerCase()))
        .map((cat) => _mapToCategory(cat))
        .toList();
    
    emit(CategoriesLoaded(categories));
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Add to mock data
    final newCategory = {
      'id': 'cat${_mockCategories.length + 1}',
      'name': event.name,
      'description': event.description,
      'color': event.color ?? '#2196F3',
      'isActive': true,
    };
    _mockCategories.add(newCategory);
    
    emit(const CategoryOperationSuccess('Category created successfully'));
    add(const LoadCategories());
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockCategories.indexWhere((cat) => cat['id'] == event.categoryId);
    if (index >= 0) {
      _mockCategories[index] = {
        ..._mockCategories[index],
        'name': event.name,
        'description': event.description,
        'color': event.color,
        'isActive': event.isActive,
      };
    }
    
    emit(const CategoryOperationSuccess('Category updated successfully'));
    add(const LoadCategories());
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    _mockCategories.removeWhere((cat) => cat['id'] == event.categoryId);
    
    emit(const CategoryOperationSuccess('Category deleted successfully'));
    add(const LoadCategories());
  }

  dynamic _mapToCategory(Map<String, dynamic> data) {
    // Return a simple map for now - in real app, use Category entity
    return data;
  }
}


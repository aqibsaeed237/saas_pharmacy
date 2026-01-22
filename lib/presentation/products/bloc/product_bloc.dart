import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/products/create_product_usecase.dart';
import '../../../domain/usecases/products/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

/// Product BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.createProductUseCase,
  }) : super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProduct>(_onCreateProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await getProductsUseCase(
      page: event.page,
      search: event.search,
      category: event.category,
    );

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(
        ProductsLoaded(
          products: products,
          hasMore: products.length >= 20,
          currentPage: event.page,
        ),
      ),
    );
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await createProductUseCase(event.product);

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(
        const ProductOperationSuccess('Product created successfully'),
      ),
    );
  }
}


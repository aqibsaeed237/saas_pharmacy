import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../api/product_api_service.dart';
import '../models/product_model.dart';

/// Product repository implementation
/// NOTE: Using mock data for UI testing - API calls are disabled
class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService apiService;

  ProductRepositoryImpl(this.apiService);

  // Mock products data
  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Paracetamol 500mg',
      description: 'Pain reliever and fever reducer',
      barcode: '1234567890123',
      sku: 'PRC-500',
      price: 5.99,
      costPrice: 3.50,
      category: 'Medications',
      tenantId: 'tenant-123',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Product(
      id: '2',
      name: 'Aspirin 100mg',
      description: 'Anti-inflammatory and pain reliever',
      barcode: '1234567890124',
      sku: 'ASP-100',
      price: 3.50,
      costPrice: 2.00,
      category: 'Medications',
      tenantId: 'tenant-123',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Product(
      id: '3',
      name: 'Ibuprofen 200mg',
      description: 'Non-steroidal anti-inflammatory drug',
      barcode: '1234567890125',
      sku: 'IBU-200',
      price: 4.99,
      costPrice: 2.50,
      category: 'Medications',
      tenantId: 'tenant-123',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? category,
  }) async {
    // MOCK DATA - No API call for UI testing
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      var filteredProducts = List<Product>.from(_mockProducts);

      // Apply search filter
      if (search != null && search.isNotEmpty) {
        filteredProducts = filteredProducts.where((product) {
          return product.name.toLowerCase().contains(search.toLowerCase()) ||
                 product.barcode!.toLowerCase().contains(search.toLowerCase()) ?? false;
        }).toList();
      }

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        filteredProducts = filteredProducts.where((product) {
          return product.category?.toLowerCase() == category.toLowerCase();
        }).toList();
      }

      // Apply pagination
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      final paginatedProducts = filteredProducts.length > startIndex
          ? filteredProducts.sublist(
              startIndex,
              endIndex > filteredProducts.length ? filteredProducts.length : endIndex,
            )
          : <Product>[];

      return Right(paginatedProducts);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    // ACTUAL API CALL - COMMENTED OUT FOR UI TESTING
    /*
    try {
      final queries = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (search != null && search.isNotEmpty) {
        queries['search'] = search;
      }
      
      if (category != null && category.isNotEmpty) {
        queries['category'] = category;
      }

      final response = await apiService.getProducts(queries);
      
      final List<dynamic> productsJson = response['data'] ?? [];
      final products = productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();

      return Right(products);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    // MOCK DATA
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final product = _mockProducts.firstWhere(
        (p) => p.id == id,
        orElse: () => _mockProducts.first,
      );
      return Right(product);
    } catch (e) {
      return Left(NotFoundFailure('Product not found'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    // MOCK DATA
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final product = _mockProducts.firstWhere(
        (p) => p.barcode == barcode,
        orElse: () => _mockProducts.first,
      );
      return Right(product);
    } catch (e) {
      return Left(NotFoundFailure('Product not found'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    // MOCK DATA
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final newProduct = product.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
      );
      _mockProducts.add(newProduct);
      return Right(newProduct);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    // MOCK DATA
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockProducts.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _mockProducts[index] = product.copyWith(updatedAt: DateTime.now());
        return Right(_mockProducts[index]);
      }
      return Left(NotFoundFailure('Product not found'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    // MOCK DATA
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _mockProducts.removeWhere((p) => p.id == id);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else {
      return UnknownFailure(exception.message);
    }
  }
}

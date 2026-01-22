import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/constants/app_enums.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../api/sale_api_service.dart';
import '../models/sale_model.dart';

/// Sale repository implementation
/// NOTE: Using mock data for UI testing - API calls are disabled
class SaleRepositoryImpl implements SaleRepository {
  final SaleApiService apiService;

  SaleRepositoryImpl(this.apiService);

  // Mock sales data
  final List<Sale> _mockSales = [];

  @override
  Future<Either<Failure, List<Sale>>> getSales({
    int page = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? staffId,
  }) async {
    // MOCK DATA - No API call for UI testing
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      var filteredSales = List<Sale>.from(_mockSales);

      // Apply date filters
      if (startDate != null) {
        filteredSales = filteredSales.where((sale) {
          return sale.createdAt.isAfter(startDate) || sale.createdAt.isAtSameMomentAs(startDate);
        }).toList();
      }

      if (endDate != null) {
        filteredSales = filteredSales.where((sale) {
          return sale.createdAt.isBefore(endDate) || sale.createdAt.isAtSameMomentAs(endDate);
        }).toList();
      }

      // Apply staff filter
      if (staffId != null && staffId.isNotEmpty) {
        filteredSales = filteredSales.where((sale) => sale.staffId == staffId).toList();
      }

      // Apply pagination
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      final paginatedSales = filteredSales.length > startIndex
          ? filteredSales.sublist(
              startIndex,
              endIndex > filteredSales.length ? filteredSales.length : endIndex,
            )
          : <Sale>[];

      return Right(paginatedSales);
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

      if (startDate != null) {
        queries['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queries['end_date'] = endDate.toIso8601String();
      }
      if (staffId != null) {
        queries['staff_id'] = staffId;
      }

      final response = await apiService.getSales(queries);

      final List<dynamic> salesJson = response['data'] ?? [];
      final sales = salesJson
          .map((json) => SaleModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();

      return Right(sales);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
  }

  @override
  Future<Either<Failure, Sale>> getSaleById(String id) async {
    // MOCK DATA
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final sale = _mockSales.firstWhere(
        (s) => s.id == id,
        orElse: () => _mockSales.first,
      );
      return Right(sale);
    } catch (e) {
      return Left(NotFoundFailure('Sale not found'));
    }
  }

  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    // MOCK DATA - No API call for UI testing
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      // Add sale to mock list
      final newSale = sale.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );

      _mockSales.insert(0, newSale); // Add to beginning

      return Right(newSale);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    // ACTUAL API CALL - COMMENTED OUT FOR UI TESTING
    /*
    try {
      final model = SaleModel(
        id: sale.id,
        invoiceNumber: sale.invoiceNumber,
        items: sale.items,
        subtotal: sale.subtotal,
        discount: sale.discount,
        tax: sale.tax,
        total: sale.total,
        paymentMethod: sale.paymentMethod,
        customerName: sale.customerName,
        customerPhone: sale.customerPhone,
        staffId: sale.staffId,
        tenantId: sale.tenantId,
        createdAt: sale.createdAt,
        updatedAt: sale.updatedAt,
      );
      
      final response = await apiService.createSale(model.toJson());
      return Right(response.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
  }

  @override
  Future<Either<Failure, String>> generateInvoiceNumber() async {
    // MOCK DATA
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return Right('INV-${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    // ACTUAL API CALL - COMMENTED OUT
    /*
    try {
      final response = await apiService.generateInvoiceNumber();
      return Right(response['invoice_number'] as String);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
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

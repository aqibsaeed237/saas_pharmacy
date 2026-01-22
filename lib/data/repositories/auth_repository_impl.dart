import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/configs/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/constants/app_enums.dart';
import '../../domain/entities/auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/auth_api_service.dart';
import '../models/auth_model.dart';

/// Authentication repository implementation
/// NOTE: Using mock data for UI testing - API calls are disabled
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.apiService,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, AuthResponse>> login(LoginRequest request) async {
    // MOCK DATA - No API call for UI testing
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      final mockUser = User(
        id: '1',
        email: request.email,
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.admin,
        isActive: true,
        tenantId: 'tenant-123',
        createdAt: DateTime.now(),
      );

      final mockAuthResponse = AuthResponse(
        user: mockUser,
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: 'tenant-123',
      );

      // Store tokens (for testing)
      await secureStorage.write(
        key: AppConfig.tokenKey,
        value: mockAuthResponse.accessToken,
      );
      await secureStorage.write(
        key: AppConfig.refreshTokenKey,
        value: mockAuthResponse.refreshToken,
      );
      await secureStorage.write(
        key: AppConfig.tenantIdKey,
        value: mockAuthResponse.tenantId,
      );

      return Right(mockAuthResponse);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    // ACTUAL API CALL - COMMENTED OUT FOR UI TESTING
    /*
    try {
      final response = await apiService.login({
        'email': request.email,
        'password': request.password,
      });

      await secureStorage.write(
        key: AppConfig.tokenKey,
        value: response.accessToken,
      );
      await secureStorage.write(
        key: AppConfig.refreshTokenKey,
        value: response.refreshToken,
      );
      await secureStorage.write(
        key: AppConfig.tenantIdKey,
        value: response.tenantId,
      );

      return Right(response.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
  }

  @override
  Future<Either<Failure, AuthResponse>> registerPharmacy(
    RegisterPharmacyRequest request,
  ) async {
    // MOCK DATA - No API call for UI testing
    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockUser = User(
        id: '1',
        email: request.email,
        firstName: request.firstName,
        lastName: request.lastName,
        role: UserRole.admin,
        isActive: true,
        tenantId: 'tenant-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );

      final mockAuthResponse = AuthResponse(
        user: mockUser,
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: mockUser.tenantId,
      );

      await secureStorage.write(
        key: AppConfig.tokenKey,
        value: mockAuthResponse.accessToken,
      );
      await secureStorage.write(
        key: AppConfig.refreshTokenKey,
        value: mockAuthResponse.refreshToken,
      );
      await secureStorage.write(
        key: AppConfig.tenantIdKey,
        value: mockAuthResponse.tenantId,
      );

      return Right(mockAuthResponse);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    // ACTUAL API CALL - COMMENTED OUT FOR UI TESTING
    /*
    try {
      final response = await apiService.registerPharmacy({
        'pharmacy_name': request.pharmacyName,
        'email': request.email,
        'password': request.password,
        'first_name': request.firstName,
        'last_name': request.lastName,
        'phone_number': request.phoneNumber,
        'address': request.address,
      });

      await secureStorage.write(
        key: AppConfig.tokenKey,
        value: response.accessToken,
      );
      await secureStorage.write(
        key: AppConfig.refreshTokenKey,
        value: response.refreshToken,
      );
      await secureStorage.write(
        key: AppConfig.tenantIdKey,
        value: response.tenantId,
      );

      return Right(response.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // MOCK - Just clear storage
    try {
      await secureStorage.delete(key: AppConfig.tokenKey);
      await secureStorage.delete(key: AppConfig.refreshTokenKey);
      await secureStorage.delete(key: AppConfig.tenantIdKey);
      await secureStorage.delete(key: AppConfig.userKey);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    // ACTUAL API CALL - COMMENTED OUT
    /*
    try {
      await apiService.logout();
      await secureStorage.delete(key: AppConfig.tokenKey);
      await secureStorage.delete(key: AppConfig.refreshTokenKey);
      await secureStorage.delete(key: AppConfig.tenantIdKey);
      await secureStorage.delete(key: AppConfig.userKey);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // MOCK DATA - Return mock user if token exists
    try {
      final token = await secureStorage.read(key: AppConfig.tokenKey);
      if (token == null) {
        return const Left(UnauthorizedFailure('Not authenticated'));
      }

      // Return mock user
      final mockUser = User(
        id: '1',
        email: 'admin@pharmacy.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.admin,
        isActive: true,
        tenantId: 'tenant-123',
        createdAt: DateTime.now(),
      );

      return Right(mockUser);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    // ACTUAL API CALL - COMMENTED OUT
    /*
    try {
      final response = await apiService.getCurrentUser();
      return Right(response.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    // MOCK - Return new mock token
    try {
      final newToken = 'mock_refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      await secureStorage.write(
        key: AppConfig.tokenKey,
        value: newToken,
      );
      return Right(newToken);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }

    // ACTUAL API CALL - COMMENTED OUT
    /*
    try {
      final refreshTokenValue = await secureStorage.read(
        key: AppConfig.refreshTokenKey,
      );

      if (refreshTokenValue == null) {
        return const Left(UnauthorizedFailure('No refresh token available'));
      }

      final response = await apiService.refreshToken({
        'refresh_token': refreshTokenValue,
      });

      final newAccessToken = response['access_token'] as String;
      
      await secureStorage.write(
        key: AppConfig.tokenKey,
        value: newAccessToken,
      );

      return Right(newAccessToken);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
    */
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.read(key: AppConfig.tokenKey);
    return token != null && token.isNotEmpty;
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

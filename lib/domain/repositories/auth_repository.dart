import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/auth.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthResponse>> login(LoginRequest request);

  /// Register a new pharmacy (tenant)
  Future<Either<Failure, AuthResponse>> registerPharmacy(
    RegisterPharmacyRequest request,
  );

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Refresh access token
  Future<Either<Failure, String>> refreshToken();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}


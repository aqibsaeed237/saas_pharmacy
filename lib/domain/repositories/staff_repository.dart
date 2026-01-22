import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';
import '../../core/constants/app_enums.dart';

/// Staff repository interface
abstract class StaffRepository {
  /// Get all staff members
  Future<Either<Failure, List<User>>> getStaff({
    int page = 1,
    int pageSize = 20,
    String? search,
    UserRole? role,
  });

  /// Get staff member by ID
  Future<Either<Failure, User>> getStaffById(String id);

  /// Create new staff member
  Future<Either<Failure, User>> createStaff({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phoneNumber,
  });

  /// Update staff member
  Future<Either<Failure, User>> updateStaff(User user);

  /// Delete staff member
  Future<Either<Failure, void>> deleteStaff(String id);

  /// Enable/disable staff member
  Future<Either<Failure, User>> toggleStaffStatus(String id, bool isActive);
}


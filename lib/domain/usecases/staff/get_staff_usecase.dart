import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/constants/app_enums.dart';
import '../../entities/user.dart';
import '../../repositories/staff_repository.dart';

/// Use case to get staff members
class GetStaffUseCase {
  final StaffRepository repository;

  GetStaffUseCase(this.repository);

  Future<Either<Failure, List<User>>> call({
    int page = 1,
    int pageSize = 20,
    String? search,
    UserRole? role,
  }) async {
    return await repository.getStaff(
      page: page,
      pageSize: pageSize,
      search: search,
      role: role,
    );
  }
}


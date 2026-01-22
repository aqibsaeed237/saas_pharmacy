import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';

/// Use case for pharmacy registration
class RegisterPharmacyUseCase {
  final AuthRepository repository;

  RegisterPharmacyUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(
    RegisterPharmacyRequest request,
  ) async {
    return await repository.registerPharmacy(request);
  }
}


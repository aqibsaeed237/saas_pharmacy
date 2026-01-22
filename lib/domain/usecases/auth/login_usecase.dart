import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/auth.dart';
import '../../repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(LoginRequest request) async {
    return await repository.login(request);
  }
}


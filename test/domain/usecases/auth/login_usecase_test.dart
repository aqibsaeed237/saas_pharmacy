import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pharmacy_pos/core/error/failures.dart';
import 'package:pharmacy_pos/core/constants/app_enums.dart';
import 'package:pharmacy_pos/domain/entities/auth.dart';
import 'package:pharmacy_pos/domain/entities/user.dart';
import 'package:pharmacy_pos/domain/repositories/auth_repository.dart';
import 'package:pharmacy_pos/domain/usecases/auth/login_usecase.dart';

@GenerateMocks([AuthRepository])
import 'login_usecase_test.mocks.dart';

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const tLoginRequest = LoginRequest(
    email: 'test@example.com',
    password: 'password123',
  );

  final tAuthResponse = AuthResponse(
    user: User(
      id: '1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.admin,
      isActive: true,
      tenantId: 'tenant1',
      createdAt: DateTime(2024, 1, 1),
    ),
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    tenantId: 'tenant1',
  );

  test('should get AuthResponse from the repository', () async {
    // arrange
    when(mockRepository.login(any))
        .thenAnswer((_) async => Right(tAuthResponse));

    // act
    final result = await useCase(tLoginRequest);

    // assert
    expect(result, Right(tAuthResponse));
    verify(mockRepository.login(tLoginRequest));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    const tFailure = NetworkFailure('Network error');
    when(mockRepository.login(any))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await useCase(tLoginRequest);

    // assert
    expect(result, const Left(tFailure));
    verify(mockRepository.login(tLoginRequest));
    verifyNoMoreInteractions(mockRepository);
  });
}


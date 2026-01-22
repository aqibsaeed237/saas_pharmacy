import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pharmacy_pos/core/error/failures.dart';
import 'package:pharmacy_pos/core/constants/app_enums.dart';
import 'package:pharmacy_pos/domain/entities/auth.dart';
import 'package:pharmacy_pos/domain/entities/user.dart';
import 'package:pharmacy_pos/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:pharmacy_pos/domain/usecases/auth/login_usecase.dart';
import 'package:pharmacy_pos/domain/usecases/auth/logout_usecase.dart';
import 'package:pharmacy_pos/domain/usecases/auth/register_pharmacy_usecase.dart';
import 'package:pharmacy_pos/presentation/authentication/bloc/auth_bloc.dart';
import 'package:pharmacy_pos/presentation/authentication/bloc/auth_event.dart';
import 'package:pharmacy_pos/presentation/authentication/bloc/auth_state.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterPharmacyUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
])
import 'auth_bloc_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterPharmacyUseCase mockRegisterPharmacyUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  final tUser =  User(
    id: '1',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    role: UserRole.admin,
    isActive: true,
    tenantId: 'tenant1',
    createdAt: DateTime(2024, 1, 1),
  );

  final tAuthResponse = AuthResponse(
    user: tUser,
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    tenantId: 'tenant1',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterPharmacyUseCase = MockRegisterPharmacyUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerPharmacyUseCase: mockRegisterPharmacyUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when login is successful',
    build: () {
      when(mockLoginUseCase(any))
          .thenAnswer((_) async => Right(tAuthResponse));
      return authBloc;
    },
    act: (bloc) => bloc.add(
      const LoginRequested(
        email: 'test@example.com',
        password: 'password123',
      ),
    ),
    expect: () => [
      const AuthLoading(),
      AuthAuthenticated(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when login fails',
    build: () {
      when(mockLoginUseCase(any))
          .thenAnswer((_) async => const Left(NetworkFailure('Network error')));
      return authBloc;
    },
    act: (bloc) => bloc.add(
      const LoginRequested(
        email: 'test@example.com',
        password: 'password123',
      ),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthError('Network error'),
    ],
  );
}


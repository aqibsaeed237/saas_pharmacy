import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/auth.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/register_pharmacy_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterPharmacyUseCase registerPharmacyUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerPharmacyUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterPharmacyRequested>(_onRegisterPharmacyRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginRequest(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResponse) {
        // Set user in router for navigation
        AppRouter.setMockUser(authResponse.user);
        emit(AuthAuthenticated(authResponse.user));
      },
    );
  }

  Future<void> _onRegisterPharmacyRequested(
    RegisterPharmacyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerPharmacyUseCase(event.request);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResponse) {
        // Set user in router for navigation
        AppRouter.setMockUser(authResponse.user);
        emit(AuthAuthenticated(authResponse.user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        AppRouter.currentUser = null;
        emit(const AuthUnauthenticated());
      },
    );
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) {
        AppRouter.setMockUser(user);
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}


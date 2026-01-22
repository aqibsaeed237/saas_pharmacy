import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Login event
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Register pharmacy event
class RegisterPharmacyRequested extends AuthEvent {
  final RegisterPharmacyRequest request;

  const RegisterPharmacyRequested(this.request);

  @override
  List<Object> get props => [request];
}

/// Logout event
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Check authentication status event
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// Get current user event
class GetCurrentUserRequested extends AuthEvent {
  const GetCurrentUserRequested();
}


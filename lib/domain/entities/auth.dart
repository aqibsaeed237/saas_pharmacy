import 'package:equatable/equatable.dart';
import 'user.dart';

/// Authentication response entity
class AuthResponse extends Equatable {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String tenantId;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.tenantId,
  });

  @override
  List<Object> get props => [user, accessToken, refreshToken, tenantId];
}

/// Login request entity
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Register pharmacy request entity
class RegisterPharmacyRequest extends Equatable {
  final String pharmacyName;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? address;

  const RegisterPharmacyRequest({
    required this.pharmacyName,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.address,
  });

  @override
  List<Object?> get props => [
        pharmacyName,
        email,
        password,
        firstName,
        lastName,
        phoneNumber,
        address,
      ];
}


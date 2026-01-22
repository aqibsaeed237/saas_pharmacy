import '../../domain/entities/auth.dart';
import 'user_model.dart';

/// Auth response model (DTO)
/// Note: JSON serialization will be added when backend is ready
class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    required super.tenantId,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Temporary implementation - will be generated when backend is ready
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tenantId: json['tenant_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    // Temporary implementation - will be generated when backend is ready
    return {
      'user': (user as UserModel).toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'tenant_id': tenantId,
    };
  }

  AuthResponse toEntity() {
    return AuthResponse(
      user: (user as UserModel).toEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      tenantId: tenantId,
    );
  }
}

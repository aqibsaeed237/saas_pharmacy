import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../configs/app_config.dart';
import '../../error/exceptions.dart';

/// Interceptor to attach authentication token and tenant ID to requests
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get token from secure storage
      final token = await _secureStorage.read(key: AppConfig.tokenKey);
      final tenantId = await _secureStorage.read(key: AppConfig.tenantIdKey);

      // Attach token to headers
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Attach tenant ID to headers
      if (tenantId != null) {
        options.headers['X-Tenant-ID'] = tenantId;
      }

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const UnauthorizedException('Failed to attach auth credentials'),
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      // Clear stored credentials
      _secureStorage.delete(key: AppConfig.tokenKey);
      _secureStorage.delete(key: AppConfig.refreshTokenKey);
      
      // You can emit an event here to trigger logout in the app
      // This would typically be handled by a global auth state manager
    }
    
    handler.next(err);
  }
}


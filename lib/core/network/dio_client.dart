import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../configs/app_config.dart';
import '../error/exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Dio client configuration for API calls
/// NOTE: API calls are disabled for UI testing - using mock data only
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    // Create Dio instance but don't make actual API calls
    // All API calls are mocked in repositories
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors disabled for UI testing
    // _dio.interceptors.addAll([
    //   LoggingInterceptor(),
    //   AuthInterceptor(_secureStorage),
    //   ErrorInterceptor(),
    // ]);
  }

  Dio get dio => _dio;

  /// Update base URL (useful for multi-tenant scenarios)
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Clear interceptors and reset
  void reset() {
    _dio.interceptors.clear();
    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(_secureStorage),
      ErrorInterceptor(),
    ]);
  }
}


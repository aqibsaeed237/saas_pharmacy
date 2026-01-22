import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

/// Interceptor to handle and transform API errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        exception = const NetworkException('Connection timeout. Please check your internet connection.');
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = err.response?.data?['message'] as String? ?? 
                       err.response?.data?['error'] as String? ?? 
                       'An error occurred';

        switch (statusCode) {
          case 400:
            exception = ValidationException(message);
            break;
          case 401:
            exception = const UnauthorizedException('Session expired. Please login again.');
            break;
          case 403:
            exception = const UnauthorizedException('Access denied.');
            break;
          case 404:
            exception = const NotFoundException('Resource not found.');
            break;
          case 500:
          case 502:
          case 503:
            exception = ServerException('Server error. Please try again later.', statusCode);
            break;
          default:
            exception = ServerException(message, statusCode);
        }
        break;

      case DioExceptionType.cancel:
        exception = const NetworkException('Request cancelled.');
        break;

      case DioExceptionType.unknown:
      default:
        if (err.error is AppException) {
          exception = err.error as AppException;
        } else {
          exception = NetworkException(
            err.message ?? 'Network error occurred. Please check your connection.',
          );
        }
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }
}


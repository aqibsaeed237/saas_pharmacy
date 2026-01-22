/// Base exception class
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, [this.statusCode]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized access']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor for logging API requests and responses (debug only)
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────');
      print('│ REQUEST: ${options.method} ${options.path}');
      print('│ Headers: ${options.headers}');
      if (options.data != null) {
        print('│ Body: ${options.data}');
      }
      print('└─────────────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────');
      print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      print('│ Data: ${response.data}');
      print('└─────────────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────');
      print('│ ERROR: ${err.type}');
      print('│ Path: ${err.requestOptions.path}');
      print('│ Message: ${err.message}');
      if (err.response != null) {
        print('│ Status: ${err.response?.statusCode}');
        print('│ Data: ${err.response?.data}');
      }
      print('└─────────────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}


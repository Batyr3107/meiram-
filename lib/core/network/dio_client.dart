import 'package:dio/dio.dart';
import 'package:shop_app/core/constants/app_constants.dart';
import 'package:shop_app/core/logger/app_logger.dart';
import 'package:shop_app/core/network/retry_interceptor.dart';

/// Enhanced Dio HTTP client with retry logic and interceptors
/// 
/// Features:
/// - Automatic retry on network failures
/// - Request/response logging
/// - Timeout configuration
/// - Error transformation
/// 
/// Usage:
/// ```dart
/// final client = DioClient();
/// final response = await client.get('/endpoint');
/// ```
class DioClient {
  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        sendTimeout: AppConstants.apiTimeout,
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll(<Interceptor>[
      _loggingInterceptor(),
      RetryInterceptor(dio: _dio),
    ]);
  }

  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  /// Logging interceptor
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (
        RequestOptions options,
        RequestInterceptorHandler handler,
      ) {
        AppLogger.apiRequest(
          options.method,
          options.uri.toString(),
          data: options.data,
        );
        handler.next(options);
      },
      onResponse: (Response<dynamic> response, ResponseInterceptorHandler handler) {
        AppLogger.apiResponse(
          response.requestOptions.method,
          response.requestOptions.uri.toString(),
          response.statusCode ?? 0,
          data: response.data,
        );
        handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        AppLogger.error(
          'API Error: ${error.message}',
          error,
          error.stackTrace,
        );
        handler.next(error);
      },
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

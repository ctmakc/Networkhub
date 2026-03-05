import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:networkhub/core/config/app_config.dart';
import 'package:networkhub/core/error/app_exception.dart';
import 'package:networkhub/core/storage/local_storage.dart';

final _logger = Logger();

class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
      if (AppConfig.isDebug) _LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () => _dio.get<T>(path, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () => _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () => _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () => _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _executeWithRetry(
      () => _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response<T>> _executeWithRetry<T>(
    Future<Response<T>> Function() request, {
    int maxAttempts = 1,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await request();
      } on DioException catch (e) {
        if (_isNetworkError(e) && attempts < maxAttempts) {
          await Future.delayed(AppConfig.retryDelay * attempts);
          continue;
        }
        rethrow;
      }
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      appException = NetworkException(
        message: 'No internet connection. Please check your network.',
        originalError: err,
      );
    } else if (err.response != null) {
      final statusCode = err.response!.statusCode ?? 0;
      final data = err.response!.data;
      String message = 'An error occurred';

      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ??
            data['error'] as String? ??
            data['detail'] as String? ??
            message;
      }

      switch (statusCode) {
        case 401:
          appException = ApiException(
            statusCode: statusCode,
            message: 'Unauthorized. Please log in again.',
            data: data,
          );
          break;
        case 403:
          appException = ApiException(
            statusCode: statusCode,
            message: 'You do not have permission to perform this action.',
            data: data,
          );
          break;
        case 404:
          appException = ApiException(
            statusCode: statusCode,
            message: 'Resource not found.',
            data: data,
          );
          break;
        case 422:
          appException = ValidationException(
            message: message,
            errors: data is Map<String, dynamic>
                ? Map<String, List<String>>.from(
                    (data['errors'] as Map<String, dynamic>? ?? {}).map(
                      (k, v) => MapEntry(k, List<String>.from(v as List)),
                    ),
                  )
                : {},
          );
          break;
        default:
          appException = ApiException(
            statusCode: statusCode,
            message: message,
            data: data,
          );
      }
    } else {
      appException = NetworkException(
        message: err.message ?? 'An unexpected error occurred',
        originalError: err,
      );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
      ),
    );
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '[API Request] ${options.method} ${options.uri}\n'
      'Headers: ${options.headers}\n'
      'Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '[API Response] ${response.statusCode} ${response.requestOptions.uri}\n'
      'Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '[API Error] ${err.requestOptions.uri}\n'
      'Error: ${err.error}\n'
      'Message: ${err.message}',
    );
    handler.next(err);
  }
}

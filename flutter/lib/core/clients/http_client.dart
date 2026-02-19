import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pc_remote_control/core/clients/api_error.dart';
import 'package:pc_remote_control/core/clients/api_response.dart';
import 'package:pc_remote_control/core/clients/logging_interceptor.dart';
import 'package:pc_remote_control/core/clients/retry_interceptor.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';
import 'package:pc_remote_control/core/settings/app_settings.dart';

class HttpClient {
  late final Dio _dio;
  final AppSettings _settings;
  final AppLogger _logger;

  HttpClient({
    required AppLogger logger,
    AppSettings? settings,
  }) : _logger = logger,
       _settings = settings ?? serviceLocator<AppSettings>() {
    final baseUrl = "${_settings.clientUrl}/api/${_settings.apiVersion}";
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
      ),
    );
    _dio.interceptors.add(
      RetryInterceptor(dio: _dio, retryConfig: _settings.retryConfig),
    );
    _dio.interceptors.add(
      LoggingInterceptor(
        logger: _logger,
        logHttpBodyInDebug: _settings.logHttpBodyInDebug,
        isDebugMode: kDebugMode,
      ),
    );
  }

  Future<ApiResponse?> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      final data = response.data;
      if (data == null) return null;

      if (data is! Map<String, dynamic>) {
        throw ApiReturnTypeError(
          message: 'Invalid type for return by api',
          errorId: '',
        );
      }

      return ApiResponse.fromMap(data);
    } on DioException catch (e) {
      throw ApiError.mapDioError(e);
    }
  }

  Future<T?> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiError.mapDioError(e);
    }
  }
}

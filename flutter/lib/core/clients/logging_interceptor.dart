import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';

//TODO: revisar o logger
class LoggingInterceptor extends Interceptor {
  static const String _requestStartedAtMicrosKey = 'log_request_started_at';
  static const String _retryAttemptKey = 'retry_attempt';
  static const List<String> _sensitiveKeys = <String>[
    'authorization',
    'token',
    'password',
    'secret',
  ];

  final AppLogger logger;
  final bool logHttpBodyInDebug;
  final bool isDebugMode;

  LoggingInterceptor({
    required this.logger,
    required this.logHttpBodyInDebug,
    required this.isDebugMode,
  });

  bool get _shouldLogBody => isDebugMode && logHttpBodyInDebug;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.extra[_requestStartedAtMicrosKey] =
        DateTime.now().microsecondsSinceEpoch;

    final context = <String, dynamic>{
      'method': options.method,
      'path': options.path,
      'uri': options.uri.toString(),
      'query': options.queryParameters,
      'attempt': _resolveAttempt(options),
    };

    if (_shouldLogBody && options.data != null) {
      context['body'] = _sanitize(options.data);
    }

    await logger.info(
      'HTTP request',
      options: LogOptions(
        tag: 'http.request',
        context: context,
      ),
    );

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final context = <String, dynamic>{
      'method': response.requestOptions.method,
      'path': response.requestOptions.path,
      'status_code': response.statusCode,
      'duration_ms': _resolveDurationMs(response.requestOptions),
      'response_size_bytes': _estimateSizeInBytes(response.data),
      'attempt': _resolveAttempt(response.requestOptions),
    };

    if (_shouldLogBody && response.data != null) {
      context['body'] = _sanitize(response.data);
    }

    await logger.info(
      'HTTP response',
      options: LogOptions(
        tag: 'http.response',
        context: context,
      ),
    );

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final context = <String, dynamic>{
      'method': requestOptions.method,
      'path': requestOptions.path,
      'uri': requestOptions.uri.toString(),
      'status_code': err.response?.statusCode,
      'dio_type': err.type.name,
      'duration_ms': _resolveDurationMs(requestOptions),
      'attempt': _resolveAttempt(requestOptions),
    };

    if (_shouldLogBody && requestOptions.data != null) {
      context['request_body'] = _sanitize(requestOptions.data);
    }
    if (_shouldLogBody && err.response?.data != null) {
      context['response_body'] = _sanitize(err.response?.data);
    }

    await logger.error(
      'HTTP request failed',
      options: LogOptions(
        tag: 'http.error',
        context: context,
        error: err.message ?? err.error,
        stackTrace: err.stackTrace,
      ),
    );

    handler.next(err);
  }

  int _resolveAttempt(RequestOptions options) {
    final attemptRaw = options.extra[_retryAttemptKey];
    final parsed = int.tryParse(attemptRaw?.toString() ?? '');
    if (parsed == null || parsed < 1) {
      return 1;
    }
    return parsed;
  }

  int _resolveDurationMs(RequestOptions options) {
    final startedAtRaw = options.extra[_requestStartedAtMicrosKey];
    final startedAtMicros = int.tryParse(startedAtRaw?.toString() ?? '');
    if (startedAtMicros == null) {
      return 0;
    }
    final elapsedMicros =
        DateTime.now().microsecondsSinceEpoch - startedAtMicros;
    return elapsedMicros ~/ 1000;
  }

  int? _estimateSizeInBytes(dynamic payload) {
    if (payload == null) {
      return null;
    }

    try {
      final encoded = jsonEncode(payload);
      return utf8.encode(encoded).length;
    } catch (_) {
      return null;
    }
  }

  dynamic _sanitize(dynamic value) {
    if (value is Map) {
      final output = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        if (_isSensitiveKey(key)) {
          output[key] = '***';
          continue;
        }
        output[key] = _sanitize(entry.value);
      }
      return output;
    }

    if (value is List) {
      return value.map(_sanitize).toList();
    }

    return value;
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    for (final sensitiveKey in _sensitiveKeys) {
      if (normalized.contains(sensitiveKey)) {
        return true;
      }
    }
    return false;
  }
}

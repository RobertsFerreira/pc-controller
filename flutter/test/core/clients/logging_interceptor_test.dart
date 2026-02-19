import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_remote_control/core/clients/logging_interceptor.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';

class RecordedLog {
  final String level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? context;

  RecordedLog({
    required this.level,
    required this.message,
    required this.tag,
    required this.context,
  });
}

class RecordingLogger implements AppLogger {
  final List<RecordedLog> records = <RecordedLog>[];

  @override
  Future<void> debug(String message, {LogOptions options = const LogOptions()}) {
    records.add(
      RecordedLog(
        level: 'debug',
        message: message,
        tag: options.tag,
        context: options.context,
      ),
    );
    return Future<void>.value();
  }

  @override
  Future<void> dispose() => Future<void>.value();

  @override
  Future<void> error(String message, {LogOptions options = const LogOptions()}) {
    records.add(
      RecordedLog(
        level: 'error',
        message: message,
        tag: options.tag,
        context: options.context,
      ),
    );
    return Future<void>.value();
  }

  @override
  Future<void> info(String message, {LogOptions options = const LogOptions()}) {
    records.add(
      RecordedLog(
        level: 'info',
        message: message,
        tag: options.tag,
        context: options.context,
      ),
    );
    return Future<void>.value();
  }

  @override
  Future<void> trace(String message, {LogOptions options = const LogOptions()}) {
    records.add(
      RecordedLog(
        level: 'trace',
        message: message,
        tag: options.tag,
        context: options.context,
      ),
    );
    return Future<void>.value();
  }

  @override
  Future<void> warn(String message, {LogOptions options = const LogOptions()}) {
    records.add(
      RecordedLog(
        level: 'warning',
        message: message,
        tag: options.tag,
        context: options.context,
      ),
    );
    return Future<void>.value();
  }
}

class StaticHttpAdapter implements HttpClientAdapter {
  final int statusCode;
  final dynamic data;

  StaticHttpAdapter({
    required this.statusCode,
    required this.data,
  });

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}

void main() {
  group('LoggingInterceptor', () {
    test('logs request and response metadata without body in release mode', () async {
      final logger = RecordingLogger();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.httpClientAdapter = StaticHttpAdapter(
        statusCode: 200,
        data: <String, dynamic>{'ok': true, 'secret': 'value'},
      );
      dio.interceptors.add(
        LoggingInterceptor(
          logger: logger,
          logHttpBodyInDebug: true,
          isDebugMode: false,
        ),
      );

      await dio.post<dynamic>(
        '/devices',
        data: <String, dynamic>{
          'token': 'abc123',
          'name': 'speaker',
        },
        queryParameters: <String, dynamic>{'id': '1'},
      );

      final requestLog = logger.records.firstWhere((record) => record.tag == 'http.request');
      final responseLog = logger.records.firstWhere((record) => record.tag == 'http.response');

      expect(requestLog.context?['method'], 'POST');
      expect(requestLog.context?['path'], '/devices');
      expect(requestLog.context?['attempt'], 1);
      expect(requestLog.context?.containsKey('body'), isFalse);

      expect(responseLog.context?['status_code'], 200);
      expect(responseLog.context?['attempt'], 1);
      expect(responseLog.context?['duration_ms'], isA<int>());
      expect(responseLog.context?.containsKey('body'), isFalse);
    });

    test('logs redacted body in debug mode', () async {
      final logger = RecordingLogger();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.httpClientAdapter = StaticHttpAdapter(
        statusCode: 200,
        data: <String, dynamic>{
          'ok': true,
          'secret': 'server-secret',
        },
      );
      dio.interceptors.add(
        LoggingInterceptor(
          logger: logger,
          logHttpBodyInDebug: true,
          isDebugMode: true,
        ),
      );

      await dio.post<dynamic>(
        '/devices',
        data: <String, dynamic>{
          'token': 'abc123',
          'name': 'speaker',
          'nested': <String, dynamic>{'password': '123456'},
        },
      );

      final requestLog = logger.records.firstWhere((record) => record.tag == 'http.request');
      final responseLog = logger.records.firstWhere((record) => record.tag == 'http.response');

      final requestBody = requestLog.context?['body'] as Map<String, dynamic>;
      final nested = requestBody['nested'] as Map<String, dynamic>;

      expect(requestBody['token'], '***');
      expect(requestBody['name'], 'speaker');
      expect(nested['password'], '***');

      final responseBody = responseLog.context?['body'] as Map<String, dynamic>;
      expect(responseBody['secret'], '***');
    });

    test('logs error metadata with status and attempt', () async {
      final logger = RecordingLogger();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.httpClientAdapter = StaticHttpAdapter(
        statusCode: 500,
        data: <String, dynamic>{'error': 'internal'},
      );
      dio.interceptors.add(
        LoggingInterceptor(
          logger: logger,
          logHttpBodyInDebug: false,
          isDebugMode: true,
        ),
      );

      try {
        await dio.get<dynamic>(
          '/fail',
          options: Options(
            extra: <String, dynamic>{'retry_attempt': 2},
          ),
        );
        fail('Expected DioException');
      } on DioException {
        final errorLog = logger.records.firstWhere((record) => record.tag == 'http.error');
        expect(errorLog.level, 'error');
        expect(errorLog.context?['status_code'], 500);
        expect(errorLog.context?['attempt'], 2);
        expect(errorLog.context?['dio_type'], DioExceptionType.badResponse.name);
        expect(errorLog.context?['duration_ms'], isA<int>());
      }
    });
  });
}

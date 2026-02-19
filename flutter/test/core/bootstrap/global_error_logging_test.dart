import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';
import 'package:pc_remote_control/core/logging/global_error_hooks.dart';

class RecordedLog {
  final String level;
  final String? tag;

  RecordedLog({
    required this.level,
    required this.tag,
  });
}

class RecordingLogger implements AppLogger {
  final List<RecordedLog> records = <RecordedLog>[];

  @override
  Future<void> debug(String message, {LogOptions options = const LogOptions()}) {
    records.add(RecordedLog(level: 'debug', tag: options.tag));
    return Future<void>.value();
  }

  @override
  Future<void> dispose() => Future<void>.value();

  @override
  Future<void> error(String message, {LogOptions options = const LogOptions()}) {
    records.add(RecordedLog(level: 'error', tag: options.tag));
    return Future<void>.value();
  }

  @override
  Future<void> info(String message, {LogOptions options = const LogOptions()}) {
    records.add(RecordedLog(level: 'info', tag: options.tag));
    return Future<void>.value();
  }

  @override
  Future<void> trace(String message, {LogOptions options = const LogOptions()}) {
    records.add(RecordedLog(level: 'trace', tag: options.tag));
    return Future<void>.value();
  }

  @override
  Future<void> warn(String message, {LogOptions options = const LogOptions()}) {
    records.add(RecordedLog(level: 'warning', tag: options.tag));
    return Future<void>.value();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Global error logging', () {
    late FlutterExceptionHandler? originalFlutterOnError;
    late bool Function(Object, StackTrace)? originalPlatformOnError;

    setUp(() {
      originalFlutterOnError = FlutterError.onError;
      originalPlatformOnError = PlatformDispatcher.instance.onError;
    });

    tearDown(() {
      FlutterError.onError = originalFlutterOnError;
      PlatformDispatcher.instance.onError = originalPlatformOnError;
    });

    test('forwards Flutter framework errors to logger', () async {
      final logger = RecordingLogger();
      configureGlobalErrorHooks(
        logger,
        presentError: (_) {},
      );

      FlutterError.onError?.call(
        FlutterErrorDetails(
          exception: StateError('flutter boom'),
          stack: StackTrace.current,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        logger.records.any((record) => record.tag == 'flutter.error'),
        isTrue,
      );
    });

    test('forwards platform errors to logger', () async {
      final logger = RecordingLogger();
      configureGlobalErrorHooks(logger);

      final handled = PlatformDispatcher.instance.onError?.call(
        Exception('platform boom'),
        StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);

      expect(handled, isTrue);
      expect(
        logger.records.any((record) => record.tag == 'platform.error'),
        isTrue,
      );
    });

    test('forwards zone errors to logger', () async {
      final logger = RecordingLogger();

      runAppWithErrorLogging(
        logger,
        () {
          throw StateError('zone boom');
        },
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        logger.records.any((record) => record.tag == 'zone.error'),
        isTrue,
      );
    });
  });
}

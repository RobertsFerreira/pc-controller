import 'package:flutter/foundation.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';
import 'package:pc_remote_control/core/logging/file_log_sink.dart';
import 'package:pc_remote_control/core/logging/log_level.dart';
import 'package:pc_remote_control/core/logging/log_record.dart';
import 'package:pc_remote_control/core/logging/log_sink.dart';

class AppLoggerImpl implements AppLogger {
  final LogLevel _minLevel;
  final bool _logToConsole;
  final LogSink? _fileSink;

  AppLoggerImpl._({
    required LogLevel minLevel,
    required bool logToConsole,
    required LogSink? fileSink,
  }) : _minLevel = minLevel,
       _logToConsole = logToConsole,
       _fileSink = fileSink;

  static Future<AppLoggerImpl> create({
    required LogLevel minLevel,
    required bool logToConsole,
    required bool logToFile,
    required String fileName,
    LogSink? fileSink,
  }) async {
    LogSink? resolvedSink = fileSink;
    if (logToFile) {
      resolvedSink ??= await FileLogSink.create(fileName: fileName);
    }

    return AppLoggerImpl._(
      minLevel: minLevel,
      logToConsole: logToConsole,
      fileSink: resolvedSink,
    );
  }

  @override
  Future<void> trace(
    String message, {
    LogOptions options = const LogOptions(),
  }) {
    return _log(LogLevel.trace, message, options: options);
  }

  @override
  Future<void> debug(
    String message, {
    LogOptions options = const LogOptions(),
  }) {
    return _log(LogLevel.debug, message, options: options);
  }

  @override
  Future<void> info(
    String message, {
    LogOptions options = const LogOptions(),
  }) {
    return _log(LogLevel.info, message, options: options);
  }

  @override
  Future<void> warn(
    String message, {
    LogOptions options = const LogOptions(),
  }) {
    return _log(LogLevel.warning, message, options: options);
  }

  @override
  Future<void> error(
    String message, {
    LogOptions options = const LogOptions(),
  }) {
    return _log(LogLevel.error, message, options: options);
  }

  @override
  Future<void> dispose() async {
    final sink = _fileSink;
    if (sink != null) {
      await sink.dispose();
    }
  }

  Future<void> _log(
    LogLevel level,
    String message, {
    LogOptions options = const LogOptions(),
  }) async {
    if (level.severity < _minLevel.severity) {
      return;
    }

    final record = LogRecord(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: options.tag,
      context: options.context,
      error: options.error,
      stackTrace: options.stackTrace,
    );
    final line = record.toJsonLine();

    if (_logToConsole) debugPrint(line);

    final sink = _fileSink;
    if (sink != null) {
      try {
        await sink.write(line);
      } catch (_) {
        if (_logToConsole) {
          debugPrint(
            '{"level":"error","tag":"logger","message":"Failed to write log to file"}',
          );
        }
      }
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  final bool _enabled;
  final Logger _logger;

  AppLogger()
    : _enabled = _resolveDefaultEnabled(),
      _logger = Logger(
        filter: _EnabledLogFilter(_resolveDefaultEnabled()),
        printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8),
      );

  bool get isEnabled => _enabled;

  void debug(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  @visibleForTesting
  static bool resolveIsEnabled({
    required bool isReleaseMode,
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    if (isWeb && !isReleaseMode) return true;
    if (!isReleaseMode) return true;

    return platform != TargetPlatform.android && platform != TargetPlatform.iOS;
  }

  static bool _resolveDefaultEnabled() {
    return resolveIsEnabled(
      isReleaseMode: kReleaseMode,
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
  }
}

class _EnabledLogFilter extends LogFilter {
  final bool _enabled;

  _EnabledLogFilter(this._enabled);

  @override
  bool shouldLog(LogEvent event) => _enabled;
}

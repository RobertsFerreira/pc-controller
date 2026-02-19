class LogOptions {
  final String? tag;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;

  const LogOptions({
    this.tag,
    this.context,
    this.error,
    this.stackTrace,
  });
}

abstract class AppLogger {
  Future<void> trace(String message, {LogOptions options = const LogOptions()});

  Future<void> debug(String message, {LogOptions options = const LogOptions()});

  Future<void> info(String message, {LogOptions options = const LogOptions()});

  Future<void> warn(String message, {LogOptions options = const LogOptions()});

  Future<void> error(String message, {LogOptions options = const LogOptions()});

  Future<void> dispose();
}

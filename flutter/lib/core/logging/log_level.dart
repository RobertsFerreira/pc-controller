//TODO: atualizar a nova versao de enums
enum LogLevel {
  trace,
  debug,
  info,
  warning,
  error;

  int get severity {
    switch (this) {
      case LogLevel.trace:
        return 0;
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
    }
  }
}

class LogLevelParser {
  static LogLevel parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'trace':
        return LogLevel.trace;
      case 'debug':
        return LogLevel.debug;
      case 'warning':
      case 'warn':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      case 'info':
      default:
        return LogLevel.info;
    }
  }
}

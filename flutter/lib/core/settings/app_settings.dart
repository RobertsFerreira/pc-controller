import 'package:pc_remote_control/core/settings/retry_config.dart';

class AppSettings {
  late final String clientUrl;
  late final String apiVersion;
  late final int maxRetries;
  late final Duration retryDelay;
  late final Duration maxRetryDelay;
  late final RetryConfig retryConfig;
  //TODO: rever a necessidade dessas vars
  late final String logLevel;
  late final bool logToConsole;
  late final bool logToFile;
  late final String logFileName;
  late final bool logHttpBodyInDebug;

  AppSettings() {
    clientUrl = String.fromEnvironment(
      'CLIENT_URL',
      defaultValue: 'http://localhost:3000',
    );

    apiVersion = String.fromEnvironment('API_VERSION');

    maxRetries = int.fromEnvironment('MAX_RETRIES', defaultValue: 3);

    retryDelay = Duration(
      milliseconds: int.fromEnvironment('RETRY_DELAY', defaultValue: 2000),
    );
    maxRetryDelay = Duration(
      milliseconds: int.fromEnvironment('MAX_RETRY_DELAY', defaultValue: 2000),
    );

    retryConfig = RetryConfig(
      maxAttempts: maxRetries,
      initialDelay: retryDelay,
      maxDelay: maxRetryDelay,
    );

    logLevel = String.fromEnvironment('LOG_LEVEL', defaultValue: 'info');
    logToConsole = bool.fromEnvironment(
      'LOG_TO_CONSOLE',
      defaultValue: true,
    );
    logToFile = bool.fromEnvironment('LOG_TO_FILE', defaultValue: true);
    logFileName = String.fromEnvironment(
      'LOG_FILE_NAME',
      defaultValue: 'pc_remote_control.log',
    );
    logHttpBodyInDebug = bool.fromEnvironment(
      'LOG_HTTP_BODY_IN_DEBUG',
      defaultValue: true,
    );
  }
}

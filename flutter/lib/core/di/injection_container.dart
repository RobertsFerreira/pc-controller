import 'package:pc_remote_control/core/clients/http_client.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';
import 'package:pc_remote_control/core/logging/app_logger_impl.dart';
import 'package:pc_remote_control/core/logging/log_level.dart';
import 'package:pc_remote_control/core/settings/app_settings.dart';

import 'service_locator.dart';

Future<void> setupDependencies() async {
  final settings = AppSettings();
  serviceLocator.registerSingleton<AppSettings>(settings);

  final logger = await AppLoggerImpl.create(
    minLevel: LogLevelParser.parse(settings.logLevel),
    logToConsole: settings.logToConsole,
    logToFile: settings.logToFile,
    fileName: settings.logFileName,
  );
  serviceLocator.registerSingleton<AppLogger>(logger);

  serviceLocator.registerLazySingleton<HttpClient>(
    () => HttpClient(
      logger: serviceLocator<AppLogger>(),
      settings: serviceLocator<AppSettings>(),
    ),
  );
}

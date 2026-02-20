import 'package:pc_remote_control/core/clients/app_logger.dart';
import 'package:pc_remote_control/core/clients/http_client.dart';
import 'package:pc_remote_control/core/settings/app_settings.dart';

import 'service_locator.dart';

void setupDependencies() async {
  final settings = AppSettings();
  serviceLocator.registerSingleton<AppSettings>(settings);
  serviceLocator.registerSingleton<AppLogger>(AppLogger());

  serviceLocator.registerLazySingleton<HttpClient>(
    () => HttpClient(
      settings: serviceLocator<AppSettings>(),
      logger: serviceLocator<AppLogger>(),
    ),
  );
}

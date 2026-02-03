import 'package:pc_remote_control/core/clients/ws_client.dart';
import 'package:pc_remote_control/core/settings/app_settings.dart';
import 'service_locator.dart';

void setupDependencies() {
  serviceLocator.registerSingleton<AppSettings>(AppSettings());
  serviceLocator.registerLazySingleton<WsClient>(
    () => WsClient(appSettings: serviceLocator()),
  );
}

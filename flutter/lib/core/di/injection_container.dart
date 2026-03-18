import 'package:pc_remote_control/core/clients/app_logger.dart';
import 'package:pc_remote_control/core/clients/http_client.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';
import 'package:pc_remote_control/core/navigation/module_registry.dart';
import 'package:pc_remote_control/core/navigation/navigation_controller.dart';
import 'package:pc_remote_control/core/settings/app_settings.dart';
import 'package:pc_remote_control/features/audio/audio_feature_module.dart';
import 'package:pc_remote_control/features/home/home_feature_module.dart';

import 'service_locator.dart';

void setupDependencies() {
  final settings = AppSettings();
  serviceLocator.registerSingleton<AppSettings>(settings);
  serviceLocator.registerSingleton<AppLogger>(AppLogger());

  serviceLocator.registerLazySingleton<HttpClient>(
    () => HttpClient(
      settings: serviceLocator<AppSettings>(),
      logger: serviceLocator<AppLogger>(),
    ),
  );

  final registry = ModuleRegistry();
  final featureModules = <FeatureModule>[
    HomeFeatureModule(),
    AudioFeatureModule(),
  ];

  for (final module in featureModules) {
    module.register(serviceLocator);
    registry.register(module.navigation);
  }

  serviceLocator.registerSingleton<ModuleRegistry>(registry);
  serviceLocator.registerSingleton<NavigationController>(
    NavigationController(registry: registry),
  );
}

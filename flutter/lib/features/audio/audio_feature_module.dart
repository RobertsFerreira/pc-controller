import 'package:pc_remote_control/core/clients/http_client.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/features/audio/services/audio_service.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_controller.dart';

void registerAudioFeatureDependencies() {
  serviceLocator.registerLazySingleton<AudioService>(
    () => AudioService(client: serviceLocator<HttpClient>()),
  );

  serviceLocator.registerLazySingleton<AudioBrowserController>(
    () => AudioBrowserController(service: serviceLocator<AudioService>()),
  );
}

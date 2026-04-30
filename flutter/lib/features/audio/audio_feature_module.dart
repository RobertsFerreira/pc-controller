import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/clients/http_client.dart';
import 'package:pc_remote_control/core/di/di_container.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';
import 'package:pc_remote_control/features/audio/audio_devices_page.dart';
import 'package:pc_remote_control/features/audio/services/audio_service.dart';
import 'package:pc_remote_control/features/audio/audio_sessions_page.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_controller.dart';

class AudioFeatureModule implements FeatureModule {
  @override
  void register(DIContainer di) {
    di.registerLazySingleton<AudioService>(
      () => AudioService(client: di<HttpClient>()),
    );
    di.registerLazySingleton<AudioBrowserController>(
      () => AudioBrowserController(service: di<AudioService>()),
    );
  }

  @override
  AppModuleNode get navigation => AppModuleNode(
    id: 'audio',
    title: 'Audio',
    icon: Icons.volume_up_outlined,
    order: 1,
    children: [
      AppModuleNode(
        id: 'audio.devices',
        title: 'Dispositivos',
        icon: Icons.speaker_outlined,
        order: 0,
        pageBuilder: (_) => const AudioDevicesPage(),
      ),
      AppModuleNode(
        id: 'audio.sessions',
        title: 'Sessoes',
        icon: Icons.graphic_eq_outlined,
        order: 1,
        pageBuilder: (_) => const AudioSessionsPage(),
      ),
    ],
  );
}

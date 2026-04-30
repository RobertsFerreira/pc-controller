import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_remote_control/features/audio/models/audio_request.dart';
import 'package:pc_remote_control/features/audio/models/audio_session.dart';
import 'package:pc_remote_control/features/audio/services/audio_service.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_controller.dart';

class MockAudioService extends Mock implements AudioService {}

void main() {
  late MockAudioService mockAudioService;
  late AudioBrowserController controller;

  setUp(() {
    mockAudioService = MockAudioService();
    controller = AudioBrowserController(service: mockAudioService);
  });

  group('AudioBrowserController', () {
    test('loads devices into state', () async {
      when(
        () => mockAudioService.listDevices(),
      ).thenAnswer(
        (_) async => [
          DeviceSound(id: 'device-1', name: 'Speakers'),
        ],
      );

      await controller.loadDevices();

      expect(controller.value.devices, hasLength(1));
      verify(() => mockAudioService.listDevices()).called(1);
    });

    test('selecting a device loads its sessions', () async {
      when(
        () => mockAudioService.listDevices(),
      ).thenAnswer(
        (_) async => [
          DeviceSound(id: 'device-1', name: 'Speakers'),
        ],
      );
      when(
        () => mockAudioService.listSessions('device-1'),
      ).thenAnswer(
        (_) async => [
          AudioSession(
            id: 'session-1',
            displayName: 'Spotify',
            volumeLevel: 55,
            state: AudioSessionState.active,
            muted: false,
          ),
        ],
      );

      await controller.loadDevices();
      await controller.selectDevice('device-1');

      expect(controller.value.sessions, hasLength(1));
      verify(() => mockAudioService.listDevices()).called(1);
      verify(() => mockAudioService.listSessions('device-1')).called(1);
    });
  });
}

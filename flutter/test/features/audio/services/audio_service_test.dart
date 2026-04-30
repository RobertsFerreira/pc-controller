import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_remote_control/core/clients/api_response.dart';
import 'package:pc_remote_control/core/clients/http_client.dart';
import 'package:pc_remote_control/features/audio/services/audio_service.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHttpClient mockHttpClient;
  late AudioService service;

  setUp(() {
    mockHttpClient = MockHttpClient();
    service = AudioService(client: mockHttpClient);
  });

  group('AudioService.listDevices', () {
    test('returns parsed device list when api returns data', () async {
      final apiResponse = ApiResponse(
        data: [
          {'id': '1', 'name': 'Speakers'},
          {'id': '2', 'name': 'Headphones'},
        ],
        headers: ResponseHeaders(timestamp: 123, count: 2),
      );

      when(
        () => mockHttpClient.get<DevicesApi>('/list_devices'),
      ).thenAnswer((_) async => apiResponse);

      final devices = await service.listDevices();

      expect(devices, hasLength(2));
      expect(devices[0].id, '1');
      expect(devices[0].name, 'Speakers');
      expect(devices[1].id, '2');
      expect(devices[1].name, 'Headphones');
      verify(() => mockHttpClient.get<DevicesApi>('/list_devices')).called(1);
    });

    test('returns empty list when api response is null', () async {
      when(() {
        return mockHttpClient.get<DevicesApi>(
          '/list_devices',
        );
      }).thenAnswer((_) async => null);

      final devices = await service.listDevices();

      expect(devices, isEmpty);
      verify(
        () => mockHttpClient.get<DevicesApi>('/list_devices'),
      ).called(1);
    });

    test('rethrows client exception', () async {
      final exception = Exception('network failed');
      when(
        () => mockHttpClient.get<DevicesApi>('/list_devices'),
      ).thenThrow(exception);

      await expectLater(service.listDevices(), throwsA(exception));
      verify(() => mockHttpClient.get<DevicesApi>('/list_devices')).called(1);
    });
  });

  group('AudioService.listSessions', () {
    test('returns parsed audio sessions when api returns data', () async {
      final apiResponse = ApiResponse(
        data: [
          {
            'id': 'session-1',
            'display_name': 'Spotify',
            'volume_level': 55.0,
            'state': 'active',
            'muted': false,
          },
        ],
        headers: ResponseHeaders(timestamp: 123, count: 1),
      );

      when(
        () => mockHttpClient.get<SessionsApi>('/list_session/device-1'),
      ).thenAnswer((_) async => apiResponse);

      final sessions = await service.listSessions('device-1');

      expect(sessions, hasLength(1));
      expect(sessions.single.id, 'session-1');
      expect(sessions.single.displayName, 'Spotify');
      expect(sessions.single.volumeLevel, 55.0);
      expect(sessions.single.state.name, 'active');
      expect(sessions.single.muted, isFalse);
      verify(
        () => mockHttpClient.get<SessionsApi>('/list_session/device-1'),
      ).called(1);
    });

    test('returns empty list when sessions api response is null', () async {
      when(() {
        return mockHttpClient.get<SessionsApi>(
          '/list_session/device-1',
        );
      }).thenAnswer((_) async => null);

      final sessions = await service.listSessions('device-1');

      expect(sessions, isEmpty);
      verify(
        () => mockHttpClient.get<SessionsApi>('/list_session/device-1'),
      ).called(1);
    });

    test('rethrows client exception for sessions request', () async {
      final exception = Exception('network failed');
      when(
        () => mockHttpClient.get<SessionsApi>('/list_session/device-1'),
      ).thenThrow(exception);

      await expectLater(service.listSessions('device-1'), throwsA(exception));
      verify(
        () => mockHttpClient.get<SessionsApi>('/list_session/device-1'),
      ).called(1);
    });
  });
}

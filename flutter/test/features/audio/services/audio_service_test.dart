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
          queryParameters: null,
        );
      }).thenAnswer((_) async => null);

      final devices = await service.listDevices();

      expect(devices, isEmpty);
      verify(() => mockHttpClient.get<DevicesApi>('/list_devices')).called(1);
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
}

import 'package:pc_remote_control/core/clients/http_client.dart';
import 'package:pc_remote_control/features/audio/models/audio_request.dart';
import 'package:pc_remote_control/features/audio/models/audio_session.dart';

typedef DevicesApi = List<Map<String, dynamic>>;
typedef SessionsApi = List<Map<String, dynamic>>;

class AudioService {
  final HttpClient client;
  AudioService({required this.client});

  Future<List<DeviceSound>> listDevices() async {
    final response = await client.get<DevicesApi>('/list_devices');

    if (response == null || response.data == null) return [];

    final devicesRaw = response.data as List;
    final devices = devicesRaw
        .cast<Map<String, dynamic>>()
        .map(DeviceSound.fromMap)
        .toList();
    return devices;
  }

  Future<List<AudioSession>> listSessions(String deviceId) async {
    final response = await client.get<SessionsApi>('/list_session/$deviceId');

    if (response == null || response.data == null) return [];

    final sessionsRaw = response.data as List;
    final sessions = sessionsRaw
        .cast<Map<String, dynamic>>()
        .map(AudioSession.fromMap)
        .toList();
    return sessions;
  }
}

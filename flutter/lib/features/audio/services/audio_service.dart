import 'package:pc_remote_control/core/clients/http_client.dart';
import 'package:pc_remote_control/features/audio/models/audio_request.dart';

typedef DevicesApi = List<Map<String, dynamic>>;

class AudioService {
  final HttpClient client;
  AudioService({required this.client});

  Future<List<DeviceSound>> listDevices() async {
    final response = await client.get<DevicesApi>('/list_devices');

    if (response == null) return [];

    final devices = response.data.map(DeviceSound.fromMap).toList();
    return devices;
  }
}

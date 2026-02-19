import 'package:map_fields/map_fields.dart';

class DeviceSound {
  final String id;
  final String name;

  DeviceSound({required this.id, required this.name});

  factory DeviceSound.fromMap(Map<String, dynamic> map) {
    final mapFields = MapFields.load(map);
    return DeviceSound(
      id: mapFields.getString('id'),
      name: mapFields.getString('name'),
    );
  }

  @override
  String toString() {
    return "ID: $id - Device name: $name";
  }
}

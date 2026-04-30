import 'package:map_fields/map_fields.dart';

class ResponseHeaders {
  final int timestamp;
  final int? count;

  ResponseHeaders({
    required this.timestamp,
    this.count,
  });

  factory ResponseHeaders.fromMap(Map<String, dynamic> map) {
    final mapFields = MapFields.load(map);
    final timestamp = mapFields.getInt('timestamp', 0);
    final count = mapFields.getIntNullable('count');

    return ResponseHeaders(timestamp: timestamp, count: count);
  }
}

class ApiResponse {
  final dynamic data;
  final ResponseHeaders headers;

  ApiResponse({
    required this.data,
    required this.headers,
  });

  factory ApiResponse.fromMap(Map<String, dynamic> map) {
    final mapFields = MapFields.load(map);
    final headers = mapFields.getMap<String, dynamic>('headers', {});

    return ApiResponse(
      data: map['data'],
      headers: ResponseHeaders.fromMap(headers),
    );
  }
}

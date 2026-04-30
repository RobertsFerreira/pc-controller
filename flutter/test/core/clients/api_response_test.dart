import 'package:flutter_test/flutter_test.dart';
import 'package:pc_remote_control/core/clients/api_response.dart';

void main() {
  test('decodes device list from api envelope', () {
    final response = ApiResponse.fromMap(
      {
        'data': [
          {'id': '1', 'name': 'Speakers'},
          {'id': '2', 'name': 'Headphones'},
        ],
        'headers': {
          'timestamp': 123,
          'count': 2,
        },
      },
    );

    expect(response.data.length, 2);
  });
}

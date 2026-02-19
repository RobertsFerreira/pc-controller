import 'package:flutter_test/flutter_test.dart';
import 'package:pc_remote_control/core/logging/log_level.dart';

void main() {
  group('LogLevelParser', () {
    test('parses known values', () {
      expect(LogLevelParser.parse('trace'), LogLevel.trace);
      expect(LogLevelParser.parse('debug'), LogLevel.debug);
      expect(LogLevelParser.parse('info'), LogLevel.info);
      expect(LogLevelParser.parse('warning'), LogLevel.warning);
      expect(LogLevelParser.parse('error'), LogLevel.error);
      expect(LogLevelParser.parse('warn'), LogLevel.warning);
    });

    test('falls back to info for unknown values', () {
      expect(LogLevelParser.parse('unknown'), LogLevel.info);
      expect(LogLevelParser.parse(''), LogLevel.info);
    });
  });
}

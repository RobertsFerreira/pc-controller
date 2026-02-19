import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';
import 'package:pc_remote_control/core/logging/app_logger_impl.dart';
import 'package:pc_remote_control/core/logging/log_level.dart';
import 'package:pc_remote_control/core/logging/log_sink.dart';

class MemoryLogSink implements LogSink {
  final List<String> lines = <String>[];

  @override
  Future<void> write(String line) async {
    lines.add(line);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('AppLoggerImpl', () {
    test('respects minimum log level and writes json lines', () async {
      final sink = MemoryLogSink();
      final logger = await AppLoggerImpl.create(
        minLevel: LogLevel.info,
        logToConsole: false,
        logToFile: true,
        fileName: 'ignored.log',
        fileSink: sink,
      );

      await logger.debug('debug message');
      await logger.info(
        'info message',
        options: const LogOptions(
          tag: 'test',
          context: <String, dynamic>{'count': 1},
        ),
      );

      expect(sink.lines.length, 1);

      final record = jsonDecode(sink.lines.first) as Map<String, dynamic>;
      expect(record['level'], 'info');
      expect(record['message'], 'info message');
      expect(record['tag'], 'test');
      expect(record['context'], <String, dynamic>{'count': 1});
      expect(record['timestamp'], isA<String>());
    });

    test('does not write to sink when logToFile is false', () async {
      final sink = MemoryLogSink();
      final logger = await AppLoggerImpl.create(
        minLevel: LogLevel.info,
        logToConsole: false,
        logToFile: false,
        fileName: 'ignored.log',
        fileSink: sink,
      );

      await logger.error('error message');

      expect(sink.lines, isEmpty);
    });
  });
}

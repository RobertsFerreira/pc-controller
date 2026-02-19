import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pc_remote_control/core/logging/log_sink.dart';

class FileLogSink implements LogSink {
  final IOSink _sink;

  FileLogSink._(this._sink);

  static Future<FileLogSink> create({
    required String fileName,
  }) async {
    final supportDir = await getApplicationSupportDirectory();
    final logsDir = Directory('${supportDir.path}${Platform.pathSeparator}logs');

    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    final file = File('${logsDir.path}${Platform.pathSeparator}$fileName');
    final sink = file.openWrite(mode: FileMode.append);
    return FileLogSink._(sink);
  }

  @override
  Future<void> write(String line) async {
    _sink.writeln(line);
    await _sink.flush();
  }

  @override
  Future<void> dispose() async {
    await _sink.flush();
    await _sink.close();
  }
}

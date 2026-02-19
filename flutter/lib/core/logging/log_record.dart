import 'dart:convert';

import 'package:pc_remote_control/core/logging/log_level.dart';

class LogRecord {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;

  LogRecord({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.context,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'timestamp': timestamp.toUtc().toIso8601String(),
      'level': level.name,
      'message': message,
    };

    if (tag != null && tag!.isNotEmpty) {
      map['tag'] = tag;
    }
    if (context != null && context!.isNotEmpty) {
      map['context'] = context;
    }
    if (error != null) {
      map['error'] = error.toString();
    }
    if (stackTrace != null) {
      map['stack_trace'] = stackTrace.toString();
    }

    return map;
  }

  String toJsonLine() {
    return jsonEncode(toMap());
  }
}

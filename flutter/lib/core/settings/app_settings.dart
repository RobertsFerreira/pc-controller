import 'package:pc_remote_control/core/settings/retry_config.dart';

class AppSettings {
  int wsPort = 3000;
  final wsPath = '/ws';
  final RetryConfig retryConfig = RetryConfig();

  String get wsUrl => 'ws://localhost:$wsPort$wsPath';
  Duration get wsTimeout => const Duration(seconds: 10);
}

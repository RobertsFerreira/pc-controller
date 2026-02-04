import 'package:pc_remote_control/core/settings/retry_config.dart';

class AppSettings {
  String wsHost = 'localhost';
  bool wsSecure = false;
  int wsPort = 3000;
  final wsPath = '/ws';
  final RetryConfig retryConfig = RetryConfig();

  String get wsUrl => '${wsSecure ? 'wss' : 'ws'}://$wsHost:$wsPort$wsPath';
  Duration get wsTimeout => const Duration(seconds: 10);
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_remote_control/core/clients/app_logger.dart';

void main() {
  group('AppLogger.resolveIsEnabled', () {
    test('enables logging when not release mode', () {
      final enabled = AppLogger.resolveIsEnabled(
        isReleaseMode: false,
        isWeb: false,
        platform: TargetPlatform.android,
      );

      expect(enabled, isTrue);
    });

    test('disables logging on mobile in release mode', () {
      final androidEnabled = AppLogger.resolveIsEnabled(
        isReleaseMode: true,
        isWeb: false,
        platform: TargetPlatform.android,
      );
      final iosEnabled = AppLogger.resolveIsEnabled(
        isReleaseMode: true,
        isWeb: false,
        platform: TargetPlatform.iOS,
      );

      expect(androidEnabled, isFalse);
      expect(iosEnabled, isFalse);
    });

    test('keeps logging enabled on windows platform in release mode', () {
      final windowsEnabled = AppLogger.resolveIsEnabled(
        isReleaseMode: true,
        isWeb: false,
        platform: TargetPlatform.windows,
      );

      expect(windowsEnabled, isTrue);
    });

    test('keeps logging disable on web platform in release mode', () {
      final webEnabled = AppLogger.resolveIsEnabled(
        isReleaseMode: true,
        isWeb: true,
        platform: TargetPlatform.android,
      );

      expect(webEnabled, isFalse);
    });
  });
}

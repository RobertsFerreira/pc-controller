import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';

typedef FlutterErrorPresenter = void Function(FlutterErrorDetails details);

//TODO: revisar o uso desse codigo
void configureGlobalErrorHooks(
  AppLogger logger, {
  FlutterErrorPresenter? presentError,
}) {
  final presenter = presentError ?? FlutterError.presentError;

  FlutterError.onError = (FlutterErrorDetails details) {
    unawaited(
      logger.error(
        'Unhandled Flutter framework error',
        options: LogOptions(
          tag: 'flutter.error',
          context: <String, dynamic>{
            'library': details.library,
            'context': details.context?.toDescription(),
          },
          error: details.exception,
          stackTrace: details.stack,
        ),
      ),
    );
    presenter(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    unawaited(
      logger.error(
        'Unhandled platform error',
        options: LogOptions(
          tag: 'platform.error',
          error: error,
          stackTrace: stackTrace,
        ),
      ),
    );
    return true;
  };
}

void runAppWithErrorLogging(AppLogger logger, void Function() runAppCallback) {
  runZonedGuarded(
    runAppCallback,
    (Object error, StackTrace stackTrace) {
      unawaited(
        logger.error(
          'Unhandled zone error',
          options: LogOptions(
            tag: 'zone.error',
            error: error,
            stackTrace: stackTrace,
          ),
        ),
      );
    },
  );
}

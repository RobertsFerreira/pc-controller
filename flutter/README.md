# pc_remote_control

Flutter client for PC Remote Control.

## Getting Started

```bash
flutter pub get
flutter run
```

## Logging Configuration

The app reads logging configuration from `--dart-define` values.

Available keys:

- `LOG_LEVEL` (`trace`, `debug`, `info`, `warning`, `error`)
- `LOG_TO_CONSOLE` (`true` or `false`)
- `LOG_TO_FILE` (`true` or `false`)
- `LOG_FILE_NAME` (for example `pc_remote_control.log`)
- `LOG_HTTP_BODY_IN_DEBUG` (`true` or `false`)

Example:

```bash
flutter run \
  --dart-define=CLIENT_URL=http://localhost:3000 \
  --dart-define=API_VERSION=v1 \
  --dart-define=LOG_LEVEL=info \
  --dart-define=LOG_TO_CONSOLE=true \
  --dart-define=LOG_TO_FILE=true \
  --dart-define=LOG_FILE_NAME=pc_remote_control.log \
  --dart-define=LOG_HTTP_BODY_IN_DEBUG=true
```

Notes:

- Logs are emitted as JSON lines.
- In debug, HTTP body logging is controlled by `LOG_HTTP_BODY_IN_DEBUG`.
- In production, HTTP logs keep metadata only (no body).

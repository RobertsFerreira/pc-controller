import 'dart:math' as math;

class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double factor;

  RetryConfig({
    this.maxAttempts = 5,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
    this.factor = 2,
  });

  Duration? nextDelay(int attempt) {
    if (attempt <= 0) {
      throw ArgumentError('Attempt number must be greater than 0');
    }
    if (attempt > maxAttempts) return null;

    final exponentialDelay =
        initialDelay.inMilliseconds * math.pow(factor, attempt - 1);

    final delay = exponentialDelay.clamp(0, maxDelay.inMilliseconds);

    return Duration(milliseconds: delay.toInt());
  }
}

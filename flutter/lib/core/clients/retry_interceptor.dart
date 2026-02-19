import 'package:dio/dio.dart';
import 'package:pc_remote_control/core/settings/retry_config.dart';

class RetryInterceptor extends Interceptor {
  static const String _retryAttemptKey = 'retry_attempt';

  final Dio dio;
  final RetryConfig retryConfig;

  RetryInterceptor({
    required this.dio,
    required this.retryConfig,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final attemptExtra = requestOptions.extra[_retryAttemptKey];
    final attempt = int.tryParse(attemptExtra.toString()) ?? 1;

    if (!_shouldRetry(err, attempt)) {
      handler.next(err);
      return;
    }

    final retryDelay = retryConfig.nextDelay(attempt);
    if (retryDelay == null) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(retryDelay);

    try {
      final retriedRequest = _copyWithAttempt(
        requestOptions,
        attempt + 1,
      );
      final response = await dio.fetch<dynamic>(retriedRequest);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  RequestOptions _copyWithAttempt(RequestOptions request, int attempt) {
    final nextExtra = Map<String, dynamic>.from(request.extra);
    nextExtra[_retryAttemptKey] = attempt;
    return request.copyWith(extra: nextExtra);
  }

  bool _shouldRetry(DioException error, int attempt) {
    if (attempt > retryConfig.maxAttempts) {
      return false;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        return statusCode == 429 || statusCode >= 500;
      default:
        return false;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:pc_remote_control/core/errors/app_error.dart';

class ApiError extends AppError {
  final int? statusCode;
  ApiError._({
    required super.message,
    required super.errorId,
    required this.statusCode,
  });

  static ApiError mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final errorId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMessage = _userMessageFromDio(error, statusCode);

    return ApiError._(
      message: '$userMessage Código de suporte: $errorId',
      errorId: errorId,
      statusCode: statusCode,
    );
  }

  static String _userMessageFromDio(DioException error, int? statusCode) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão excedido. Tente novamente.';
      case DioExceptionType.connectionError:
        return 'Não foi possível conectar ao servidor. Verifique sua rede.';
      case DioExceptionType.badResponse:
        if (statusCode == 401 || statusCode == 403) {
          return 'Acesso não autorizado para esta operação.';
        }
        if (statusCode == 404) {
          return 'Recurso não encontrado.';
        }
        if (statusCode == 429) {
          return 'Muitas tentativas. Aguarde alguns instantes.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'O servidor está indisponível no momento.';
        }
        return 'Falha na requisição.';
      case DioExceptionType.cancel:
        return 'A requisição foi cancelada.';
      default:
        return 'Erro inesperado ao comunicar com o servidor.';
    }
  }
}

class ApiReturnTypeError extends AppError {
  ApiReturnTypeError({
    required super.message,
    required super.errorId,
  });
}

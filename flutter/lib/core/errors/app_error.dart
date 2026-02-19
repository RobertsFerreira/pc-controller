class AppError implements Exception {
  final String message;
  final String errorId;

  AppError({
    required this.message,
    required this.errorId,
  });

  @override
  String toString() {
    return '$message (errorId: $errorId)';
  }
}

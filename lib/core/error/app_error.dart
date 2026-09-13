class AppError implements Exception {
  final String message;
  final Object? originalError;

  AppError(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'AppError: $message (Details: $originalError)';
    }
    return 'AppError: $message';
  }
}

abstract class AppException implements Exception {
  final String message;
  const AppException({required this.message});

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  final Object? originalError;

  const NetworkException({
    required super.message,
    this.originalError,
  });
}

class ApiException extends AppException {
  final int statusCode;
  final dynamic data;

  const ApiException({
    required super.message,
    required this.statusCode,
    this.data,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}

class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException({
    required super.message,
    required this.errors,
  });

  String get firstError {
    if (errors.isEmpty) return message;
    final firstKey = errors.keys.first;
    final firstErrors = errors[firstKey] ?? [];
    return firstErrors.isNotEmpty ? firstErrors.first : message;
  }
}

class StorageException extends AppException {
  const StorageException({required super.message});
}

class OcrException extends AppException {
  const OcrException({required super.message});
}

class PermissionException extends AppException {
  final String permission;

  const PermissionException({
    required super.message,
    required this.permission,
  });
}

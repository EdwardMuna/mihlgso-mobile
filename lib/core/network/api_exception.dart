/// Normalized error surfaced to the UI layer for any failed API call.
/// Screens should only ever need message + type — never raw Dio/HTTP detail.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.fieldErrors,
  });

  final String message;
  final ApiExceptionType type;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() => message;
}

enum ApiExceptionType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  conflict,
  server,
  unknown,
}

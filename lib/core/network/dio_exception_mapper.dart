import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// The single boundary between Dio and the rest of the app: [DioException] →
/// typed [AppException]. This file and `DioClient` are the only ones that
/// import Dio. HTTP status codes are translated here — the layers above deal in
/// [AppException]/`Failure`, never in Dio types.
AppException mapDioException(DioException e) => switch (e.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.transformTimeout => const TimeoutException(),
  DioExceptionType.connectionError => const NetworkException(),
  DioExceptionType.badCertificate => const ServerException(
    'Could not establish a secure connection.',
  ),
  DioExceptionType.cancel => const UnknownException('Request was cancelled.'),
  DioExceptionType.badResponse => _fromStatus(e.response),
  // `unknown` is usually a SocketException (DNS/host lookup) → offline.
  DioExceptionType.unknown => const NetworkException(),
};

AppException _fromStatus(Response<dynamic>? response) {
  final code = response?.statusCode;
  return switch (code) {
    401 => const UnauthorizedException(),
    403 => const ForbiddenException(),
    404 => const NotFoundException(),
    422 => ValidationException(_apiMessage(response) ?? 'Validation failed'),
    429 => const RateLimitException(),
    _ when code != null && code >= 500 => ServerException(
      'Server error ($code). Please try again.',
      code,
    ),
    _ => ServerException(
      code == null
          ? 'The server returned an error. Please try again.'
          : 'The server returned an error ($code). Please try again.',
      code,
    ),
  };
}

/// Best-effort extraction of an API-provided error message (e.g. 422 details).
String? _apiMessage(Response<dynamic>? response) {
  final data = response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return null;
}

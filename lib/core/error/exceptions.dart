/// Low-level exceptions thrown by the data layer.
///
/// Data sources throw these; repositories turn them into [Failure]s via
/// [mapExceptionToFailure]. No Dio/HTTP types leak in here — [mapDioException]
/// is the single place that knows Dio.
library;

/// Base type for everything the data layer can throw.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

/// No network connectivity (host lookup failed, connection refused, etc.).
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// The request outlived its connect/send/receive timeout.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'The request timed out']);
}

/// 401 — missing/expired credentials.
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized'])
    : super(statusCode: 401);
}

/// 403 — authenticated but not allowed.
class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Forbidden'])
    : super(statusCode: 403);
}

/// 404 — resource not found.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found'])
    : super(statusCode: 404);
}

/// 422 — request understood but validation failed.
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed'])
    : super(statusCode: 422);
}

/// 429 — too many requests.
class RateLimitException extends AppException {
  const RateLimitException([super.message = 'Too many requests'])
    : super(statusCode: 429);
}

/// 500+ — the server errored.
class ServerException extends AppException {
  const ServerException([super.message = 'Server error', int? statusCode])
    : super(statusCode: statusCode);
}

/// A response arrived but wasn't in the expected shape.
class ParseException extends AppException {
  const ParseException([super.message = 'Unexpected data format']);
}

/// The cache was read but held no (or unreadable) data.
class CacheException extends AppException {
  const CacheException([super.message = 'No cached data available']);
}

/// Anything we didn't anticipate.
class UnknownException extends AppException {
  const UnknownException([super.message = 'Unexpected error']);
}

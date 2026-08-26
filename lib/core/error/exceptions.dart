/// Low-level exceptions thrown by the data layer.
///
/// Data sources throw these; the repository catches them and maps them to
/// [Failure]s so the domain/presentation layers never deal with raw errors.
library;

/// Thrown when the remote API responds with a non-success status or the
/// request fails at the transport level.
class ServerException implements Exception {
  const ServerException([this.message = 'Server error']);
  final String message;
}

/// Thrown when there is no network connectivity.
class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);
  final String message;
}

/// Thrown when the cache is read but holds no (or unreadable) data.
class CacheException implements Exception {
  const CacheException([this.message = 'No cached data available']);
  final String message;
}

/// Thrown when a response is received but does not contain the expected data.
class ParseException implements Exception {
  const ParseException([this.message = 'Unexpected data format']);
  final String message;
}

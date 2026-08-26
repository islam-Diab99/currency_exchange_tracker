import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// The device has no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// The request took too long and timed out.
class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The request timed out. Please try again.',
  ]);
}

/// 401 — credentials missing or expired.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has expired. Please sign in again.',
  ]);
}

/// 403 — not allowed to access this resource.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'You don’t have access to this.']);
}

/// 404 — resource not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'We couldn’t find what you were looking for.',
  ]);
}

/// 422 — the server rejected the input.
class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Please check your input and try again.',
  ]);
}

/// 429 — too many requests.
class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Too many requests. Please slow down.',
  ]);
}

/// The API failed or returned a 500+ error response.
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

/// No cached data was available to fall back on.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No saved data available yet.']);
}

/// The response could not be parsed into the expected shape.
class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Received unexpected data.']);
}

/// An error we didn't anticipate.
class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

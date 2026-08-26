import 'exceptions.dart';
import 'failures.dart';

/// The single place that turns a data-layer [AppException] into a domain
/// [Failure]. Add a case here once; every repository picks it up via
/// `ResultGuard`. Connectivity/auth copy is owned by the [Failure] (stable,
/// localizable); server/validation/parse messages are contextual so they pass
/// through.
Failure mapExceptionToFailure(Object error) => switch (error) {
  NetworkException() => const NetworkFailure(),
  TimeoutException() => const TimeoutFailure(),
  UnauthorizedException() => const UnauthorizedFailure(),
  ForbiddenException() => const ForbiddenFailure(),
  NotFoundException() => const NotFoundFailure(),
  RateLimitException() => const RateLimitFailure(),
  ValidationException(:final message) => ValidationFailure(message),
  ServerException(:final message) => ServerFailure(message),
  ParseException(:final message) => ParseFailure(message),
  CacheException(:final message) => CacheFailure(message),
  _ => const UnknownFailure(),
};

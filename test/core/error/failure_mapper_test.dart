import 'package:axis_assessment/core/error/exceptions.dart';
import 'package:axis_assessment/core/error/failure_mapper.dart';
import 'package:axis_assessment/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapExceptionToFailure', () {
    test('maps each AppException to its matching Failure', () {
      expect(
        mapExceptionToFailure(const NetworkException()),
        isA<NetworkFailure>(),
      );
      expect(
        mapExceptionToFailure(const TimeoutException()),
        isA<TimeoutFailure>(),
      );
      expect(
        mapExceptionToFailure(const UnauthorizedException()),
        isA<UnauthorizedFailure>(),
      );
      expect(
        mapExceptionToFailure(const ForbiddenException()),
        isA<ForbiddenFailure>(),
      );
      expect(
        mapExceptionToFailure(const NotFoundException()),
        isA<NotFoundFailure>(),
      );
      expect(
        mapExceptionToFailure(const RateLimitException()),
        isA<RateLimitFailure>(),
      );
      expect(
        mapExceptionToFailure(const CacheException()),
        isA<CacheFailure>(),
      );
    });

    test('passes through contextual messages for server/validation/parse', () {
      expect(
        mapExceptionToFailure(const ServerException('boom')),
        isA<ServerFailure>().having((f) => f.message, 'message', 'boom'),
      );
      expect(
        mapExceptionToFailure(const ValidationException('bad input')),
        isA<ValidationFailure>().having(
          (f) => f.message,
          'message',
          'bad input',
        ),
      );
      expect(
        mapExceptionToFailure(const ParseException('weird shape')),
        isA<ParseFailure>().having((f) => f.message, 'message', 'weird shape'),
      );
    });

    test('falls back to UnknownFailure for an unrecognised error', () {
      expect(mapExceptionToFailure(Exception('?')), isA<UnknownFailure>());
      expect(mapExceptionToFailure(ArgumentError('?')), isA<UnknownFailure>());
    });
  });
}

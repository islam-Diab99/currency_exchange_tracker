import 'package:dartz/dartz.dart';

import 'failure_mapper.dart';
import 'failures.dart';

/// Mix into a repository to run data-layer calls without hand-written
/// try/catch. Any thrown [AppException] — or any [Error] — becomes the right
/// [Failure] via [mapExceptionToFailure]. One place, every repository.
mixin ResultGuard {
  Future<Either<Failure, T>> guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } catch (error) {
      return Left(mapExceptionToFailure(error));
    }
  }
}

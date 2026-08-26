import 'package:dartz/dartz.dart';

import '../error/failures.dart';

abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Placeholder for use cases that take no arguments.
class NoParams {
  const NoParams();
}

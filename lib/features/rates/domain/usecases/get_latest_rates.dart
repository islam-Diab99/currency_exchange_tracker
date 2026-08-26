import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rates_snapshot.dart';
import '../repositories/rates_repository.dart';

class GetLatestRates implements UseCase<RatesSnapshot, NoParams> {
  const GetLatestRates(this._repository);
  final RatesRepository _repository;

  @override
  Future<Either<Failure, RatesSnapshot>> call(NoParams params) =>
      _repository.getLatestRates();
}

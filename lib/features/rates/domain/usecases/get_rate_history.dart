import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rate_point.dart';
import '../repositories/rates_repository.dart';

class GetRateHistory implements UseCase<List<RatePoint>, RateHistoryParams> {
  const GetRateHistory(this._repository);
  final RatesRepository _repository;

  @override
  Future<Either<Failure, List<RatePoint>>> call(RateHistoryParams params) =>
      _repository.getRateHistory(params.currencyCode, days: params.days);
}

class RateHistoryParams extends Equatable {
  const RateHistoryParams({required this.currencyCode, this.days = 7});
  final String currencyCode;
  final int days;

  @override
  List<Object?> get props => [currencyCode, days];
}

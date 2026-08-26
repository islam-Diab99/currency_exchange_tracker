import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/rate_point.dart';
import '../entities/rates_snapshot.dart';

abstract interface class RatesRepository {
  Future<Either<Failure, RatesSnapshot>> getLatestRates();

  Future<Either<Failure, List<RatePoint>>> getRateHistory(
    String currencyCode, {
    int days = 7,
  });
}

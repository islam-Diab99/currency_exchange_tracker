import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/rates_snapshot.dart';

abstract interface class RatesRepository {
  Future<Either<Failure, RatesSnapshot>> getLatestRates();
}

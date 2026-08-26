import 'package:axis_assessment/features/rates/data/model/rates_response_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/entities/rates_snapshot.dart';
import '../../domain/repositories/rates_repository.dart';
import '../../domain/supported_currencies.dart';
import '../datasources/rates_remote_data_source.dart';

class RatesRepositoryImpl implements RatesRepository {
  RatesRepositoryImpl(this._remote);
  final RatesRemoteDataSource _remote;

  @override
  Future<Either<Failure, RatesSnapshot>> getLatestRates() async {
    try {
      final today = await _remote.getLatestRates();
      final yesterday = await _tryPreviousDay(today.date);

      final rates = <ExchangeRate>[];
      for (final c in SupportedCurrencies.all) {
        final rate = _invert(today.rawRateFor(c.responseKey));
        if (rate == null) continue;
        rates.add(
          ExchangeRate(
            currency: c,
            rate: rate,
            previousRate: _invert(yesterday?.rawRateFor(c.responseKey)),
          ),
        );
      }

      if (rates.isEmpty) {
        return const Left(ParseFailure('No rates in the response.'));
      }
      return Right(RatesSnapshot(rates: rates, lastUpdated: DateTime.now()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ParseException catch (e) {
      return Left(ParseFailure(e.message));
    }
  }

  Future<RatesResponseModel?> _tryPreviousDay(DateTime latest) async {
    final prev = DateTime(
      latest.year,
      latest.month,
      latest.day,
    ).subtract(const Duration(days: 1));
    try {
      return await _remote.getRatesForDate(prev);
    } on ServerException {
      return null; // change just won't show for missing days
    }
  }

  /// EGP→foreign  ->  EGP per one foreign unit.
  double? _invert(double? raw) => (raw == null || raw <= 0) ? null : 1 / raw;
}

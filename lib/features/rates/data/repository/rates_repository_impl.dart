import 'package:axis_assessment/features/rates/data/model/rates_response_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/entities/rate_point.dart';
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
      final now = DateTime.now();
      final yesterdayDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 1));

      // Today's value comes from the reliable `/latest/` endpoint; yesterday's
      // date is derived from the clock so both can be fetched concurrently.
      // If today fails, the whole load fails; a missing yesterday is tolerated.
      final results = await Future.wait<RatesResponseModel?>([
        _remote.getLatestRates(),
        _tryDay(yesterdayDate),
      ]);
      final today = results[0]!;
      final yesterday = results[1];

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

  Future<RatesResponseModel?> _tryDay(DateTime date) async {
    try {
      return await _remote.getRatesForDate(date);
    } on ServerException {
      return null; // change just won't show for missing days
    }
  }

  @override
  Future<Either<Failure, List<RatePoint>>> getRateHistory(
    String currencyCode, {
    int days = 7,
  }) async {
    final key = currencyCode.toLowerCase();
    try {
      final latest = await _remote.getLatestRates();
      final anchor = DateTime(
        latest.date.year,
        latest.date.month,
        latest.date.day,
      );

      // Fetch the older days concurrently; tolerate individual misses.
      final older = await Future.wait(
        List.generate(days - 1, (i) => i + 1).map((offset) async {
          try {
            return await _remote.getRatesForDate(
              anchor.subtract(Duration(days: offset)),
            );
          } on ServerException {
            return null;
          }
        }),
      );

      final points = <RatePoint>[];
      for (final res in [latest, ...older]) {
        if (res == null) continue;
        final rate = _invert(res.rawRateFor(key));
        if (rate == null) continue;
        points.add(
          RatePoint(
            date: DateTime(res.date.year, res.date.month, res.date.day),
            rate: rate,
          ),
        );
      }
      points.sort((a, b) => a.date.compareTo(b.date));

      if (points.isEmpty) {
        return const Left(
          ParseFailure('No historical data for this currency.'),
        );
      }
      return Right(points);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ParseException catch (e) {
      return Left(ParseFailure(e.message));
    }
  }

  /// EGP→foreign  ->  EGP per one foreign unit.
  double? _invert(double? raw) => (raw == null || raw <= 0) ? null : 1 / raw;
}

import 'package:axis_assessment/features/rates/data/model/rates_response_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result_guard.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/entities/rate_point.dart';
import '../../domain/entities/rates_snapshot.dart';
import '../../domain/repositories/rates_repository.dart';
import '../../domain/supported_currencies.dart';
import '../datasources/rates_local_data_source.dart';
import '../datasources/rates_remote_data_source.dart';

class RatesRepositoryImpl with ResultGuard implements RatesRepository {
  RatesRepositoryImpl({
    required RatesRemoteDataSource remote,
    required RatesLocalDataSource local,
    required NetworkInfo network,
  }) : _remote = remote,
       _local = local,
       _network = network;

  final RatesRemoteDataSource _remote;
  final RatesLocalDataSource _local;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, RatesSnapshot>> getLatestRates() async {
    // Offline: don't attempt the network (it would only hang until the Dio
    // connect timeout) — serve the last good snapshot straight from cache.
    if (!await _network.isConnected) {
      return _cachedOr(const NetworkFailure());
    }

    // `guard` maps any thrown exception to a Failure.
    final result = await guard<RatesSnapshot>(() async {
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
        throw const ParseException('No rates in the response.');
      }

      final snapshot = RatesSnapshot(rates: rates, lastUpdated: DateTime.now());
      await _local.cacheSnapshot(snapshot);
      return snapshot;
    });

    // Any load failure (incl. a transport-level error, or an empty response)
    // falls back to the last good snapshot if we have one.
    return result.fold(_cachedOr, (snapshot) async => Right(snapshot));
  }

  /// Returns cached data if present, otherwise the given [failure]. Lets a
  /// failed/offline load fall back to the last good snapshot instead of erroring.
  Future<Either<Failure, RatesSnapshot>> _cachedOr(Failure failure) async {
    if (!_local.hasCache) return Left(failure);
    try {
      return Right(await _local.getCachedSnapshot());
    } on CacheException {
      return Left(failure);
    }
  }

  Future<RatesResponseModel?> _tryDay(DateTime date) async {
    try {
      return await _remote.getRatesForDate(date);
    } on AppException {
      return null; // a single day's blip shouldn't fail the whole load
    }
  }

  @override
  Future<Either<Failure, List<RatePoint>>> getRateHistory(
    String currencyCode, {
    int days = 7,
  }) async {
    // Offline: fail fast. There's no history cache to fall back on (unlike
    // getLatestRates), so surface the network failure without hitting Dio.
    if (!await _network.isConnected) return const Left(NetworkFailure());

    final key = currencyCode.toLowerCase();
    return guard(() async {
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
          } on AppException {
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
        throw const ParseException('No historical data for this currency.');
      }
      return points;
    });
  }

  /// EGP→foreign  ->  EGP per one foreign unit.
  double? _invert(double? raw) => (raw == null || raw <= 0) ? null : 1 / raw;
}

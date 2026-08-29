import 'package:axis_assessment/core/error/exceptions.dart';
import 'package:axis_assessment/core/error/failures.dart';
import 'package:axis_assessment/features/rates/data/repository/rates_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockRatesRemoteDataSource remote;
  late MockRatesLocalDataSource local;
  late MockNetworkInfo network;
  late RatesRepositoryImpl repository;

  setUpAll(registerTestFallbacks);

  setUp(() {
    remote = MockRatesRemoteDataSource();
    local = MockRatesLocalDataSource();
    network = MockNetworkInfo();
    repository = RatesRepositoryImpl(
      remote: remote,
      local: local,
      network: network,
    );
  });

  void goOnline() =>
      when(() => network.isConnected).thenAnswer((_) async => true);
  void goOffline() =>
      when(() => network.isConnected).thenAnswer((_) async => false);

  group('getLatestRates — online', () {
    setUp(() {
      goOnline();
      when(() => local.cacheSnapshot(any())).thenAnswer((_) async {});
    });

    test('inverts raw rates to EGP-per-unit and caches the snapshot', () async {
      when(
        () => remote.getLatestRates(),
      ).thenAnswer((_) async => responseModel());
      when(
        () => remote.getRatesForDate(any()),
      ).thenAnswer((_) async => responseModel(rawRates: const {'usd': 0.0195}));

      final result = await repository.getLatestRates();

      final snap = result.getOrElse(() => throw StateError('expected Right'));
      expect(snap.rates, hasLength(5));
      final usdRate = snap.rates.firstWhere((r) => r.currency.code == 'USD');
      // 1 / 0.019227 ≈ 52.01 EGP per USD.
      expect(usdRate.rate, closeTo(52.01, 0.01));
      expect(usdRate.previousRate, isNotNull);
      expect(snap.fromCache, isFalse);
      verify(() => local.cacheSnapshot(any())).called(1);
    });

    test("stamps lastUpdated with the API's data date, not now", () async {
      when(
        () => remote.getLatestRates(),
      ).thenAnswer((_) async => responseModel(date: DateTime(2026, 6, 1)));
      when(
        () => remote.getRatesForDate(any()),
      ).thenAnswer((_) async => responseModel());

      final result = await repository.getLatestRates();

      final snap = result.getOrElse(() => throw StateError('expected Right'));
      expect(snap.lastUpdated, DateTime(2026, 6, 1));
    });

    test("tolerates a missing yesterday — previousRate is null", () async {
      when(
        () => remote.getLatestRates(),
      ).thenAnswer((_) async => responseModel());
      when(
        () => remote.getRatesForDate(any()),
      ).thenThrow(const NetworkException());

      final result = await repository.getLatestRates();

      final snap = result.getOrElse(() => throw StateError('expected Right'));
      final usdRate = snap.rates.firstWhere((r) => r.currency.code == 'USD');
      expect(usdRate.previousRate, isNull);
    });

    test('falls back to cache when the network load throws', () async {
      when(() => remote.getLatestRates()).thenThrow(const NetworkException());
      when(() => local.hasCache).thenReturn(true);
      when(
        () => local.getCachedSnapshot(),
      ).thenAnswer((_) async => snapshot(fromCache: true));

      final result = await repository.getLatestRates();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => throw StateError('r')).fromCache, isTrue);
    });

    test(
      'returns the failure when the load throws and no cache exists',
      () async {
        when(() => remote.getLatestRates()).thenThrow(const NetworkException());
        when(() => local.hasCache).thenReturn(false);

        final result = await repository.getLatestRates();

        expect(result.isLeft(), isTrue);
      },
    );

    test('an empty response with no cache surfaces a ParseFailure', () async {
      when(
        () => remote.getLatestRates(),
      ).thenAnswer((_) async => responseModel(rawRates: const {}));
      when(
        () => remote.getRatesForDate(any()),
      ).thenAnswer((_) async => responseModel(rawRates: const {}));
      when(() => local.hasCache).thenReturn(false);

      final result = await repository.getLatestRates();

      result.fold(
        (f) => expect(f, isA<ParseFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('getLatestRates — offline', () {
    setUp(goOffline);

    test('serves the cached snapshot without touching the network', () async {
      when(() => local.hasCache).thenReturn(true);
      when(
        () => local.getCachedSnapshot(),
      ).thenAnswer((_) async => snapshot(fromCache: true));

      final result = await repository.getLatestRates();

      expect(result.getOrElse(() => throw StateError('r')).fromCache, isTrue);
      verifyNever(() => remote.getLatestRates());
    });

    test('returns NetworkFailure when there is no cache', () async {
      when(() => local.hasCache).thenReturn(false);

      final result = await repository.getLatestRates();

      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected a Left'),
      );
      verifyNever(() => remote.getLatestRates());
    });
  });

  group('getRateHistory — online', () {
    setUp(goOnline);

    test('returns the available points sorted oldest-first', () async {
      when(
        () => remote.getLatestRates(),
      ).thenAnswer((_) async => responseModel(date: DateTime(2026, 6, 7)));
      // Echo each requested date back so we get seven distinct points.
      when(() => remote.getRatesForDate(any())).thenAnswer((invocation) async {
        final date = invocation.positionalArguments.first as DateTime;
        return responseModel(date: date);
      });

      final result = await repository.getRateHistory('USD');

      final points = result.getOrElse(() => throw StateError('r'));
      expect(points, hasLength(7));
      expect(points.first.date.isBefore(points.last.date), isTrue);
      expect(points.every((p) => p.rate > 0), isTrue);
    });

    test('tolerates failing days and still returns the anchor point', () async {
      when(
        () => remote.getLatestRates(),
      ).thenAnswer((_) async => responseModel(date: DateTime(2026, 6, 7)));
      when(
        () => remote.getRatesForDate(any()),
      ).thenThrow(const ServerException());

      final result = await repository.getRateHistory('USD');

      expect(result.getOrElse(() => throw StateError('r')), hasLength(1));
    });

    test(
      'surfaces ParseFailure when the currency is absent everywhere',
      () async {
        when(
          () => remote.getLatestRates(),
        ).thenAnswer((_) async => responseModel(rawRates: const {}));
        when(
          () => remote.getRatesForDate(any()),
        ).thenThrow(const ServerException());

        final result = await repository.getRateHistory('USD');

        result.fold(
          (f) => expect(f, isA<ParseFailure>()),
          (_) => fail('expected a Left'),
        );
      },
    );
  });

  group('getRateHistory — offline', () {
    setUp(goOffline);

    test(
      'fails fast with NetworkFailure and never calls the network',
      () async {
        final result = await repository.getRateHistory('USD');

        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('expected a Left'),
        );
        verifyNever(() => remote.getLatestRates());
      },
    );
  });
}

import 'package:axis_assessment/core/error/failures.dart';
import 'package:axis_assessment/features/rates/domain/entities/rates_snapshot.dart';
import 'package:axis_assessment/features/rates/presentation/bloc/rates_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockGetLatestRates getLatestRates;
  late MockNetworkInfo networkInfo;

  setUpAll(registerTestFallbacks);

  setUp(() {
    getLatestRates = MockGetLatestRates();
    networkInfo = MockNetworkInfo();
    // The bloc subscribes to this in its constructor; keep it inert so tests
    // drive connectivity through explicit events instead of stream timing.
    when(
      () => networkInfo.onConnectivityChanged,
    ).thenAnswer((_) => const Stream<bool>.empty());
  });

  RatesListBloc build() =>
      RatesListBloc(getLatestRates: getLatestRates, networkInfo: networkInfo);

  void stubLatest(Either<Failure, RatesSnapshot> result) =>
      when(() => getLatestRates(any())).thenAnswer((_) async => result);

  group('RatesListRequested', () {
    blocTest<RatesListBloc, RatesListState>(
      'emits [loading, success] with the fresh snapshot',
      setUp: () => stubLatest(Right(snapshot())),
      build: build,
      act: (bloc) => bloc.add(const RatesListRequested()),
      expect: () => [
        const RatesListState(status: RatesListStatus.loading),
        RatesListState(
          status: RatesListStatus.success,
          snapshot: snapshot(),
          isOffline: false,
        ),
      ],
    );

    blocTest<RatesListBloc, RatesListState>(
      'flags offline when the success came from cache',
      setUp: () => stubLatest(Right(snapshot(fromCache: true))),
      build: build,
      act: (bloc) => bloc.add(const RatesListRequested()),
      expect: () => [
        const RatesListState(status: RatesListStatus.loading),
        RatesListState(
          status: RatesListStatus.success,
          snapshot: snapshot(fromCache: true),
          isOffline: true,
        ),
      ],
    );

    blocTest<RatesListBloc, RatesListState>(
      'emits [loading, failure] with the error message',
      setUp: () => stubLatest(const Left(ServerFailure('down'))),
      build: build,
      act: (bloc) => bloc.add(const RatesListRequested()),
      expect: () => [
        const RatesListState(status: RatesListStatus.loading),
        const RatesListState(
          status: RatesListStatus.failure,
          errorMessage: 'down',
        ),
      ],
    );
  });

  group('RatesListRefreshed', () {
    blocTest<RatesListBloc, RatesListState>(
      'a refresh returning cache is a soft failure that keeps the data',
      setUp: () => stubLatest(Right(snapshot(fromCache: true))),
      build: build,
      act: (bloc) => bloc.add(const RatesListRefreshed()),
      expect: () => [
        const RatesListState(status: RatesListStatus.loading),
        RatesListState(
          status: RatesListStatus.failure,
          snapshot: snapshot(fromCache: true),
          errorMessage: 'No internet connection.',
          isOffline: true,
        ),
      ],
    );
  });

  group('RatesListConnectivityChanged', () {
    blocTest<RatesListBloc, RatesListState>(
      'going offline raises the banner without reloading',
      build: build,
      act: (bloc) =>
          bloc.add(const RatesListConnectivityChanged(isConnected: false)),
      expect: () => [const RatesListState(isOffline: true)],
      verify: (_) => verifyNever(() => getLatestRates(any())),
    );

    blocTest<RatesListBloc, RatesListState>(
      'reconnecting silently auto-refreshes (no loading state)',
      setUp: () => stubLatest(Right(snapshot())),
      build: build,
      act: (bloc) =>
          bloc.add(const RatesListConnectivityChanged(isConnected: true)),
      expect: () => [
        RatesListState(
          status: RatesListStatus.success,
          snapshot: snapshot(),
          isOffline: false,
        ),
      ],
    );

    blocTest<RatesListBloc, RatesListState>(
      'ignores a reconnect while a load is already in flight',
      build: build,
      seed: () => const RatesListState(status: RatesListStatus.loading),
      act: (bloc) =>
          bloc.add(const RatesListConnectivityChanged(isConnected: true)),
      expect: () => const <RatesListState>[],
      verify: (_) => verifyNever(() => getLatestRates(any())),
    );
  });
}

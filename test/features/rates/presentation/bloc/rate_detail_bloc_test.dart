import 'package:axis_assessment/core/error/failures.dart';
import 'package:axis_assessment/features/rates/domain/entities/rate_point.dart';
import 'package:axis_assessment/features/rates/presentation/bloc/rate_detail/rate_detail_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetRateHistory getRateHistory;

  final points = [
    RatePoint(date: DateTime(2026, 6, 1), rate: 52.0),
    RatePoint(date: DateTime(2026, 6, 2), rate: 52.4),
  ];

  setUpAll(registerTestFallbacks);

  setUp(() => getRateHistory = MockGetRateHistory());

  RateDetailBloc build() => RateDetailBloc(getRateHistory: getRateHistory);

  blocTest<RateDetailBloc, RateDetailState>(
    'emits [loading, success] with the history points',
    setUp: () => when(() => getRateHistory(any()))
        .thenAnswer((_) async => Right(points)),
    build: build,
    act: (bloc) => bloc.add(const RateHistoryRequested('USD')),
    expect: () => [
      const RateDetailState(status: RateDetailStatus.loading),
      RateDetailState(status: RateDetailStatus.success, points: points),
    ],
  );

  blocTest<RateDetailBloc, RateDetailState>(
    'emits [loading, failure] with the error message',
    setUp: () => when(() => getRateHistory(any()))
        .thenAnswer((_) async => const Left(NetworkFailure())),
    build: build,
    act: (bloc) => bloc.add(const RateHistoryRequested('USD')),
    expect: () => [
      const RateDetailState(status: RateDetailStatus.loading),
      const RateDetailState(
        status: RateDetailStatus.failure,
        errorMessage: 'No internet connection.',
      ),
    ],
  );
}

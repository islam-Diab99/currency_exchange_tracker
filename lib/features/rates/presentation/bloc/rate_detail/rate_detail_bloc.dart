import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/rate_point.dart';
import '../../../domain/usecases/get_rate_history.dart';

part 'rate_detail_event.dart';
part 'rate_detail_state.dart';

class RateDetailBloc extends Bloc<RateDetailEvent, RateDetailState> {
  RateDetailBloc({required GetRateHistory getRateHistory})
    : _getRateHistory = getRateHistory,
      super(const RateDetailState()) {
    on<RateHistoryRequested>(_onRequested);
  }

  final GetRateHistory _getRateHistory;

  Future<void> _onRequested(
    RateHistoryRequested event,
    Emitter<RateDetailState> emit,
  ) async {
    emit(state.copyWith(status: RateDetailStatus.loading, clearError: true));
    final result = await _getRateHistory(
      RateHistoryParams(currencyCode: event.currencyCode),
    );
    result.fold(
      (f) => emit(
        state.copyWith(
          status: RateDetailStatus.failure,
          errorMessage: f.message,
        ),
      ),
      (points) => emit(
        state.copyWith(status: RateDetailStatus.success, points: points),
      ),
    );
  }
}

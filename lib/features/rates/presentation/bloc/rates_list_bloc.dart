import 'package:axis_assessment/core/usecases/usecase.dart';
import 'package:axis_assessment/features/rates/domain/entities/rates_snapshot.dart';
import 'package:axis_assessment/features/rates/domain/usecases/get_latest_rates.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'rates_list_event.dart';
part 'rates_list_state.dart';

class RatesListBloc extends Bloc<RatesListEvent, RatesListState> {
  RatesListBloc({required GetLatestRates getLatestRates})
    : _getLatestRates = getLatestRates,
      super(const RatesListState()) {
    on<RatesListRequested>(_onRequested);
    on<RatesListRefreshed>(_onRefreshed);
  }

  final GetLatestRates _getLatestRates;

  Future<void> _onRequested(
    RatesListRequested event,
    Emitter<RatesListState> emit,
  ) async {
    emit(state.copyWith(status: RatesListStatus.loading, clearError: true));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    RatesListRefreshed event,
    Emitter<RatesListState> emit,
  ) async {
    await _load(emit); // no loading state: RefreshIndicator shows its own
  }

  Future<void> _load(Emitter<RatesListState> emit) async {
    final result = await _getLatestRates(const NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          status: RatesListStatus.failure,
          errorMessage: f.message,
        ),
      ),
      (snapshot) => emit(
        state.copyWith(
          status: RatesListStatus.success,
          snapshot: snapshot,
          clearError: true,
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:axis_assessment/core/network/network_info.dart';
import 'package:axis_assessment/core/usecases/usecase.dart';
import 'package:axis_assessment/features/rates/domain/entities/rates_snapshot.dart';
import 'package:axis_assessment/features/rates/domain/usecases/get_latest_rates.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'rates_list_event.dart';
part 'rates_list_state.dart';

class RatesListBloc extends Bloc<RatesListEvent, RatesListState> {
  RatesListBloc({
    required GetLatestRates getLatestRates,
    required NetworkInfo networkInfo,
  }) : _getLatestRates = getLatestRates,
       _networkInfo = networkInfo,
       super(const RatesListState()) {
    on<RatesListRequested>(_onRequested);
    on<RatesListRefreshed>(_onRefreshed);
    on<RatesListConnectivityChanged>(_onConnectivity);

    _sub = _networkInfo.onConnectivityChanged.listen(
      (connected) => add(RatesListConnectivityChanged(isConnected: connected)),
    );
  }

  final GetLatestRates _getLatestRates;
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _sub;

  Future<void> _onRequested(
    RatesListRequested event,
    Emitter<RatesListState> emit,
  ) async {
    emit(state.copyWith(status: RatesListStatus.loading, clearError: true));
    await _load(emit, isRefresh: false);
  }

  Future<void> _onRefreshed(
    RatesListRefreshed event,
    Emitter<RatesListState> emit,
  ) async {
    // A transient loading tick guarantees the result below is a fresh emission,
    // so the snackbar re-fires and the RefreshIndicator settles even on a
    // repeated pull. It shows no skeleton (we already have data).
    emit(state.copyWith(status: RatesListStatus.loading));
    await _load(emit, isRefresh: true);
  }

  Future<void> _onConnectivity(
    RatesListConnectivityChanged event,
    Emitter<RatesListState> emit,
  ) async {
    if (!event.isConnected) {
      emit(state.copyWith(isOffline: true)); // banner appears immediately
      return;
    }
    if (state.status == RatesListStatus.loading) return;
    await _load(emit, isRefresh: false); // reconnected → silent auto-refresh
  }

  Future<void> _load(
    Emitter<RatesListState> emit, {
    required bool isRefresh,
  }) async {
    final result = await _getLatestRates(const NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          status: RatesListStatus.failure,
          errorMessage: f.message,
        ),
      ),
      (snapshot) {
        // A user-initiated refresh that comes back as cached data means we
        // couldn't reach the network: keep the cached rates on screen but flag
        // it as a soft failure so the snackbar fires. (Initial loads stay
        // silent — the offline banner is enough there.)
        if (isRefresh && snapshot.fromCache) {
          emit(
            state.copyWith(
              status: RatesListStatus.failure,
              snapshot: snapshot,
              errorMessage: 'No internet connection.',
              isOffline: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: RatesListStatus.success,
              snapshot: snapshot,
              clearError: true,
              isOffline:
                  snapshot.fromCache, // cache fallback keeps us "offline"
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

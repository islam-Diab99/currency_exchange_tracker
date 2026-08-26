part of 'rates_list_bloc.dart';

enum RatesListStatus { initial, loading, success, failure }

class RatesListState extends Equatable {
  const RatesListState({
    this.status = RatesListStatus.initial,
    this.snapshot,
    this.errorMessage,
    this.isOffline = false,
  });

  final RatesListStatus status;
  final RatesSnapshot? snapshot;
  final String? errorMessage;

  /// True when we lost connectivity or are showing a cache fallback — drives
  /// the offline banner on the list screen.
  final bool isOffline;

  bool get hasData => (snapshot?.rates.isNotEmpty) ?? false;

  RatesListState copyWith({
    RatesListStatus? status,
    RatesSnapshot? snapshot,
    String? errorMessage,
    bool clearError = false,
    bool? isOffline,
  }) {
    return RatesListState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [status, snapshot, errorMessage, isOffline];
}

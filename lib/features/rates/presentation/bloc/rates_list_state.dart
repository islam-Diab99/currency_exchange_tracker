part of 'rates_list_bloc.dart';

enum RatesListStatus { initial, loading, success, failure }

class RatesListState extends Equatable {
  const RatesListState({
    this.status = RatesListStatus.initial,
    this.snapshot,
    this.errorMessage,
  });

  final RatesListStatus status;
  final RatesSnapshot? snapshot;
  final String? errorMessage;

  bool get hasData => (snapshot?.rates.isNotEmpty) ?? false;

  RatesListState copyWith({
    RatesListStatus? status,
    RatesSnapshot? snapshot,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RatesListState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, snapshot, errorMessage];
}

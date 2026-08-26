part of 'rate_detail_bloc.dart';

sealed class RateDetailEvent extends Equatable {
  const RateDetailEvent();
  @override
  List<Object?> get props => [];
}

class RateHistoryRequested extends RateDetailEvent {
  const RateHistoryRequested(this.currencyCode);
  final String currencyCode;
  @override
  List<Object?> get props => [currencyCode];
}

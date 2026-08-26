part of 'rates_list_bloc.dart';

sealed class RatesListEvent extends Equatable {
  const RatesListEvent();
  @override
  List<Object?> get props => [];
}

class RatesListRequested extends RatesListEvent {
  const RatesListRequested();
}

class RatesListRefreshed extends RatesListEvent {
  const RatesListRefreshed();
}

import 'package:equatable/equatable.dart';

import 'exchange_rate.dart';

class RatesSnapshot extends Equatable {
  const RatesSnapshot({required this.rates, required this.lastUpdated});

  final List<ExchangeRate> rates;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [rates, lastUpdated];
}

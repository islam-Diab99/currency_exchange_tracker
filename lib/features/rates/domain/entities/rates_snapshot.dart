import 'package:equatable/equatable.dart';

import 'exchange_rate.dart';

class RatesSnapshot extends Equatable {
  const RatesSnapshot({
    required this.rates,
    required this.lastUpdated,
    this.fromCache = false,
  });

  final List<ExchangeRate> rates;
  final DateTime lastUpdated;

  /// True when the snapshot was rebuilt from the local cache rather than a
  /// fresh network load — the list screen uses this to show the offline banner.
  final bool fromCache;

  RatesSnapshot copyWith({bool? fromCache}) => RatesSnapshot(
    rates: rates,
    lastUpdated: lastUpdated,
    fromCache: fromCache ?? this.fromCache,
  );

  @override
  List<Object?> get props => [rates, lastUpdated, fromCache];
}

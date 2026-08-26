import 'package:equatable/equatable.dart';

import 'currency.dart';

/// How EGP moved against a currency between two days.
enum RateTrend { egpStronger, egpWeaker, flat }

class ExchangeRate extends Equatable {
  const ExchangeRate({
    required this.currency,
    required this.rate,
    this.previousRate,
  });

  final Currency currency;
  final double rate;
  final double? previousRate;

  double get changeAbsolute {
    final prev = previousRate;
    if (prev == null) return 0;
    return rate - prev;
  }

  double get changePercent {
    final prev = previousRate;
    if (prev == null || prev == 0) return 0;
    return (rate - prev) / prev * 100;
  }

  /// A *lower* rate means one unit costs fewer EGP → EGP strengthened.
  RateTrend get trend {
    if (previousRate == null || changeAbsolute == 0) return RateTrend.flat;
    return changeAbsolute < 0 ? RateTrend.egpStronger : RateTrend.egpWeaker;
  }

  @override
  List<Object?> get props => [currency, rate, previousRate];
}

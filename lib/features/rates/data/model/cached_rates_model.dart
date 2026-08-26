import '../../domain/entities/currency.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/entities/rates_snapshot.dart';
import '../../domain/supported_currencies.dart';

/// Serializable snapshot. Only codes + numbers are stored; [Currency] metadata
/// is rebuilt from [SupportedCurrencies] on read.
class CachedRatesModel {
  const CachedRatesModel({required this.lastUpdated, required this.rates});

  final DateTime lastUpdated;
  final List<CachedRate> rates;

  factory CachedRatesModel.fromSnapshot(RatesSnapshot s) => CachedRatesModel(
    lastUpdated: s.lastUpdated,
    rates: s.rates
        .map((r) => CachedRate(r.currency.code, r.rate, r.previousRate))
        .toList(),
  );

  factory CachedRatesModel.fromMap(Map<dynamic, dynamic> map) =>
      CachedRatesModel(
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          (map['lastUpdated'] as num).toInt(),
        ),
        rates: ((map['rates'] as List?) ?? [])
            .whereType<Map>()
            .map(
              (m) => CachedRate(
                m['code'] as String,
                (m['rate'] as num).toDouble(),
                (m['previousRate'] as num?)?.toDouble(),
              ),
            )
            .toList(),
      );

  Map<String, dynamic> toMap() => {
    'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    'rates': rates
        .map(
          (r) => {'code': r.code, 'rate': r.rate, 'previousRate': r.previous},
        )
        .toList(),
  };

  RatesSnapshot toSnapshot() {
    final list = <ExchangeRate>[];
    for (final r in rates) {
      final currency = _currencyFor(r.code);
      if (currency == null) continue; // drop codes we no longer support
      list.add(
        ExchangeRate(
          currency: currency,
          rate: r.rate,
          previousRate: r.previous,
        ),
      );
    }
    return RatesSnapshot(
      rates: list,
      lastUpdated: lastUpdated,
      fromCache: true,
    );
  }

  static Currency? _currencyFor(String code) {
    for (final c in SupportedCurrencies.all) {
      if (c.code == code) return c;
    }
    return null;
  }
}

class CachedRate {
  const CachedRate(this.code, this.rate, this.previous);
  final String code;
  final double rate;
  final double? previous;
}

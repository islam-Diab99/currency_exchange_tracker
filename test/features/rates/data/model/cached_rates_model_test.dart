import 'package:axis_assessment/features/rates/data/model/cached_rates_model.dart';
import 'package:axis_assessment/features/rates/domain/entities/exchange_rate.dart';
import 'package:axis_assessment/features/rates/domain/entities/rates_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CachedRatesModel round-trip', () {
    test('snapshot -> map -> snapshot preserves the data', () {
      final original = RatesSnapshot(
        rates: [ExchangeRate(currency: usd, rate: 52.01, previousRate: 51.00)],
        lastUpdated: DateTime(2026, 6, 1, 12, 30),
      );

      final map = CachedRatesModel.fromSnapshot(original).toMap();
      final restored = CachedRatesModel.fromMap(map).toSnapshot();

      expect(restored.lastUpdated, original.lastUpdated);
      expect(restored.rates.single.currency, usd);
      expect(restored.rates.single.rate, 52.01);
      expect(restored.rates.single.previousRate, 51.00);
    });

    test('marks a restored snapshot as coming from cache', () {
      final map = CachedRatesModel.fromSnapshot(snapshot()).toMap();

      final restored = CachedRatesModel.fromMap(map).toSnapshot();

      expect(restored.fromCache, isTrue);
    });

    test('preserves a null previous rate', () {
      final original = RatesSnapshot(
        rates: [ExchangeRate(currency: usd, rate: 52.01)],
        lastUpdated: DateTime(2026, 6, 1),
      );

      final map = CachedRatesModel.fromSnapshot(original).toMap();
      final restored = CachedRatesModel.fromMap(map).toSnapshot();

      expect(restored.rates.single.previousRate, isNull);
    });

    test('drops currency codes that are no longer supported', () {
      final map = {
        'lastUpdated': DateTime(2026, 6, 1).millisecondsSinceEpoch,
        'rates': [
          {'code': 'USD', 'rate': 52.01, 'previousRate': 51.00},
          {'code': 'XYZ', 'rate': 1.0, 'previousRate': null},
        ],
      };

      final restored = CachedRatesModel.fromMap(map).toSnapshot();

      expect(restored.rates, hasLength(1));
      expect(restored.rates.single.currency.code, 'USD');
    });
  });
}

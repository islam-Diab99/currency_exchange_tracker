import 'package:axis_assessment/features/rates/domain/entities/exchange_rate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  ExchangeRate rate({required double now, double? prev}) =>
      ExchangeRate(currency: usd, rate: now, previousRate: prev);

  group('ExchangeRate.changeAbsolute', () {
    test('is 0 when there is no previous rate', () {
      expect(rate(now: 52).changeAbsolute, 0);
    });

    test('is the signed difference from the previous rate', () {
      expect(rate(now: 51, prev: 52).changeAbsolute, closeTo(-1, 1e-9));
      expect(rate(now: 53, prev: 52).changeAbsolute, closeTo(1, 1e-9));
    });
  });

  group('ExchangeRate.changePercent', () {
    test('is 0 when there is no previous rate', () {
      expect(rate(now: 52).changePercent, 0);
    });

    test('guards against division by zero', () {
      expect(rate(now: 52, prev: 0).changePercent, 0);
    });

    test('is the percentage move relative to the previous rate', () {
      expect(rate(now: 51, prev: 52).changePercent, closeTo(-1.923, 0.001));
    });
  });

  group('ExchangeRate.trend', () {
    test('is flat without a previous rate', () {
      expect(rate(now: 52).trend, RateTrend.flat);
    });

    test('is flat when the rate is unchanged', () {
      expect(rate(now: 52, prev: 52).trend, RateTrend.flat);
    });

    test('a falling rate means EGP strengthened (fewer EGP per unit)', () {
      // 1 USD costs less EGP than yesterday → EGP is stronger.
      expect(rate(now: 51, prev: 52).trend, RateTrend.egpStronger);
    });

    test('a rising rate means EGP weakened (more EGP per unit)', () {
      expect(rate(now: 53, prev: 52).trend, RateTrend.egpWeaker);
    });
  });
}

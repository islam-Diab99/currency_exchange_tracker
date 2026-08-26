import 'package:axis_assessment/core/utils/rate_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The formatter uses a Unicode minus sign (U+2212), not a hyphen, so the
  // sign column stays visually aligned with '+'.
  const minus = '−';

  group('RateFormatter.rate — decimal precision scales with magnitude', () {
    test('>= 100 keeps 2 decimals', () {
      expect(RateFormatter.rate(150.126), '150.13');
    });

    test('[1, 100) keeps 3 decimals', () {
      expect(RateFormatter.rate(52.0102), '52.010');
    });

    test('[0.1, 1) keeps 4 decimals', () {
      expect(RateFormatter.rate(0.33), '0.3300');
    });

    test('< 0.1 keeps 5 decimals', () {
      expect(RateFormatter.rate(0.019227), '0.01923');
    });
  });

  group('RateFormatter.signedPercent', () {
    test('prefixes a positive value with +', () {
      expect(RateFormatter.signedPercent(1.234), '+1.23%');
    });

    test('prefixes a negative value with a Unicode minus', () {
      expect(RateFormatter.signedPercent(-2), '${minus}2.00%');
    });

    test('has no sign for zero', () {
      expect(RateFormatter.signedPercent(0), '0.00%');
    });
  });

  group('RateFormatter.signedChange', () {
    test('signs the value and scales decimals by magnitude', () {
      expect(RateFormatter.signedChange(0.5), '+0.5000');
      expect(RateFormatter.signedChange(-0.5), '${minus}0.5000');
    });
  });
}

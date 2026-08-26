import 'package:axis_assessment/core/error/exceptions.dart';
import 'package:axis_assessment/features/rates/data/model/rates_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RatesResponseModel.fromJson', () {
    test('parses the base-currency map and the date', () {
      final json = {
        'date': '2026-06-01',
        'egp': {'usd': 0.019227, 'eur': 0.016523},
      };

      final model = RatesResponseModel.fromJson(json, base: 'egp');

      expect(model.date, DateTime(2026, 6, 1));
      expect(model.rawRateFor('usd'), 0.019227);
      expect(model.rawRateFor('eur'), 0.016523);
    });

    test('lowercases keys so lookups are case-insensitive', () {
      final json = {
        'date': '2026-06-01',
        'egp': {'USD': 0.019227},
      };

      final model = RatesResponseModel.fromJson(json, base: 'egp');

      expect(model.rawRateFor('usd'), 0.019227);
      expect(model.rawRateFor('USD'), 0.019227);
    });

    test('coerces numeric strings to doubles', () {
      final json = {
        'date': '2026-06-01',
        'egp': {'usd': '0.019227'},
      };

      final model = RatesResponseModel.fromJson(json, base: 'egp');

      expect(model.rawRateFor('usd'), 0.019227);
    });

    test('skips values that are not numbers', () {
      final json = {
        'date': '2026-06-01',
        'egp': {'usd': 'not-a-number'},
      };

      final model = RatesResponseModel.fromJson(json, base: 'egp');

      expect(model.rawRateFor('usd'), isNull);
    });

    test('throws ParseException when the base map is missing', () {
      final json = {'date': '2026-06-01'};

      expect(
        () => RatesResponseModel.fromJson(json, base: 'egp'),
        throwsA(isA<ParseException>()),
      );
    });

    test('falls back to a non-null date when it is missing', () {
      final json = {
        'egp': {'usd': 0.019227},
      };

      final model = RatesResponseModel.fromJson(json, base: 'egp');

      expect(model.date, isNotNull);
    });

    test('rawRateFor returns null for an unknown currency', () {
      final model = RatesResponseModel.fromJson({
        'date': '2026-06-01',
        'egp': {'usd': 0.019227},
      }, base: 'egp');

      expect(model.rawRateFor('xyz'), isNull);
    });
  });
}

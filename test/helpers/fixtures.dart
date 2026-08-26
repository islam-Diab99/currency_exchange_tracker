import 'package:axis_assessment/features/rates/data/model/rates_response_model.dart';
import 'package:axis_assessment/features/rates/domain/entities/currency.dart';
import 'package:axis_assessment/features/rates/domain/entities/exchange_rate.dart';
import 'package:axis_assessment/features/rates/domain/entities/rates_snapshot.dart';
import 'package:axis_assessment/features/rates/domain/supported_currencies.dart';

/// The USD currency from the app's supported list — handy for single-currency
/// assertions.
final Currency usd = SupportedCurrencies.all.firstWhere((c) => c.code == 'USD');

/// Raw EGP→foreign rates for all five supported currencies (as the API returns
/// them). `1 / 0.019227 ≈ 52.01 EGP per USD`.
const Map<String, double> kRawRates = {
  'usd': 0.019227,
  'eur': 0.016523,
  'gbp': 0.014282,
  'sar': 0.072100,
  'jpy': 3.030303,
};

/// A parsed API response with the given raw (EGP→foreign) rates.
RatesResponseModel responseModel({
  DateTime? date,
  Map<String, double>? rawRates,
}) {
  return RatesResponseModel(
    date: date ?? DateTime(2026, 6, 1),
    rates: rawRates ?? kRawRates,
  );
}

/// A domain snapshot with a single USD rate. [fromCache] mirrors what the
/// repository sets when it serves the local cache.
RatesSnapshot snapshot({bool fromCache = false}) {
  return RatesSnapshot(
    rates: [
      ExchangeRate(currency: usd, rate: 52.01, previousRate: 51.00),
    ],
    lastUpdated: DateTime(2026, 6, 1, 12),
    fromCache: fromCache,
  );
}

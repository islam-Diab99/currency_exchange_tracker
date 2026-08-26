import '../../../../core/error/exceptions.dart';

/// Parsed `{ "date": "...", "egp": { "usd": 0.019, ... } }`.
/// Keeps raw EGP→foreign values; inversion happens in the repository.
class RatesResponseModel {
  const RatesResponseModel({required this.date, required this.rates});

  final DateTime date;
  final Map<String, double> rates;

  factory RatesResponseModel.fromJson(
    Map<String, dynamic> json, {
    required String base,
  }) {
    final rawRates = json[base];
    if (rawRates is! Map) {
      throw const ParseException('Missing base-currency rates');
    }
    final rates = <String, double>{};
    rawRates.forEach((k, v) {
      final d = v is num ? v.toDouble() : double.tryParse('$v');
      if (d != null) rates[k.toString().toLowerCase()] = d;
    });
    final rawDate = json['date'];
    return RatesResponseModel(
      date: rawDate is String ? DateTime.parse(rawDate) : DateTime.now(),
      rates: rates,
    );
  }

  double? rawRateFor(String key) => rates[key.toLowerCase()];
}

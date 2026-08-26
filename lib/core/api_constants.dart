class ApiConstants {
  const ApiConstants._();

  static const String latestBaseUrl =
      'https://latest.currency-api.pages.dev/v1/currencies';

  static String historicalBaseUrl(String date) =>
      'https://$date.currency-api.pages.dev/v1/currencies';

  static const String baseCurrency = 'egp';

  static String get ratesPath => '$baseCurrency.json';

  static const int historyDays = 7;
}

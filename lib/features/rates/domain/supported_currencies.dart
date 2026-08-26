import 'entities/currency.dart';

class SupportedCurrencies {
  const SupportedCurrencies._();

  static const List<Currency> all = [
    Currency(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
    Currency(code: 'GBP', name: 'British Pound', flag: '🇬🇧'),
    Currency(code: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦'),
    Currency(code: 'JPY', name: 'Japanese Yen', flag: '🇯🇵'),
  ];
}

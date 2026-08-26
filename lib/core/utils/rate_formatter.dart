class RateFormatter {
  const RateFormatter._();

  static int _decimals(double v) {
    final a = v.abs();
    if (a >= 100) return 2;
    if (a >= 1) return 3;
    if (a >= 0.1) return 4;
    return 5;
  }

  static String rate(double v) => v.toStringAsFixed(_decimals(v));

  static String signedChange(double v) {
    final sign = v > 0 ? '+' : (v < 0 ? '−' : '');
    return '$sign${v.abs().toStringAsFixed(_decimals(v))}';
  }

  static String signedPercent(double v) {
    final sign = v > 0 ? '+' : (v < 0 ? '−' : '');
    return '$sign${v.abs().toStringAsFixed(2)}%';
  }
}

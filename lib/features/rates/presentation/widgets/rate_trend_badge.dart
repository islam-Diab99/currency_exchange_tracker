import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rate_formatter.dart';
import '../../domain/entities/exchange_rate.dart';

/// Resolves the muted color + directional glyph for a rate's daily trend.
class TrendVisual {
  const TrendVisual(this.color, this.icon);
  final Color color;
  final IconData icon;

  factory TrendVisual.of(ExchangeRate rate, Brightness brightness) {
    return switch (rate.trend) {
      RateTrend.egpStronger => TrendVisual(
        AppColors.up(brightness),
        Icons.arrow_outward_rounded,
      ),
      RateTrend.egpWeaker => TrendVisual(
        AppColors.down(brightness),
        Icons.south_east_rounded,
      ),
      RateTrend.flat => TrendVisual(
        AppColors.muted(brightness),
        Icons.remove_rounded,
      ),
    };
  }
}

/// A restrained, minimal trend indicator: a fine directional glyph and the
/// day's percentage, in a muted tone. No loud fills — the elegance is in
/// the quiet.
class RateTrendBadge extends StatelessWidget {
  const RateTrendBadge({super.key, required this.rate});

  final ExchangeRate rate;

  @override
  Widget build(BuildContext context) {
    final visual = TrendVisual.of(rate, Theme.of(context).brightness);
    final hasHistory = rate.previousRate != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(visual.icon, size: 13, color: visual.color),
        const SizedBox(width: 3),
        Text(
          hasHistory ? RateFormatter.signedPercent(rate.changePercent) : '—',
          style: TextStyle(
            color: visual.color,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            letterSpacing: 0.1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

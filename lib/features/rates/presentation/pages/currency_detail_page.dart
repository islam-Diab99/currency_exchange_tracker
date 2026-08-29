import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rate_formatter.dart';
import '../../domain/entities/exchange_rate.dart';
import '../bloc/rate_detail/rate_detail_bloc.dart';
import '../widgets/chart_shimmer.dart';
import '../widgets/rate_history_chart.dart';
import '../widgets/rate_trend_badge.dart';

/// Screen 2 — a single currency's current rate, daily change, and a smooth
/// 7-day history chart, dressed in the same obsidian-and-gold language.
class CurrencyDetailPage extends StatelessWidget {
  const CurrencyDetailPage({
    super.key,
    required this.rate,
    required this.lastUpdated,
  });

  final ExchangeRate rate;
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = rate.currency;
    final lineColor = TrendVisual.of(rate, theme.brightness).color;

    return Scaffold(
      appBar: AppBar(title: Text('${c.code} / EGP')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          _SummaryCard(rate: rate, lastUpdated: lastUpdated),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Text(
                  'LAST 7 DAYS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: lineColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${c.code} / EGP',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
              child: SizedBox(
                height: 260,
                child: BlocBuilder<RateDetailBloc, RateDetailState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        // Cross-fade, with the incoming child easing up slightly.
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _chartContent(context, state, c.code, lineColor),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the chart-area widget for the current state, each tagged with a
  /// distinct key so [AnimatedSwitcher] can cross-fade between them.
  Widget _chartContent(
    BuildContext context,
    RateDetailState state,
    String code,
    Color lineColor,
  ) {
    switch (state.status) {
      case RateDetailStatus.loading:
      case RateDetailStatus.initial:
        return const ChartShimmer(key: ValueKey('chart-shimmer'));
      case RateDetailStatus.failure:
        return _ChartError(
          key: const ValueKey('chart-error'),
          message: state.errorMessage,
          onRetry: () =>
              context.read<RateDetailBloc>().add(RateHistoryRequested(code)),
        );
      case RateDetailStatus.success:
        return state.hasData
            ? RateHistoryChart(
                key: const ValueKey('chart-data'),
                points: state.points,
                color: lineColor,
              )
            : const _ChartEmpty(key: ValueKey('chart-empty'));
    }
  }
}

/// The obsidian "metal card" summary — mirrors the list header's signature.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.rate, required this.lastUpdated});

  final ExchangeRate rate;
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final c = rate.currency;
    // The card is always dark, so resolve trend tones against a dark ground.
    final visual = TrendVisual.of(rate, Brightness.dark);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E232D), Color(0xFF0A0C10)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.goldSoft.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.goldSoft.withValues(alpha: 0.28),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GoldFlag(flag: c.flag),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFF3F0EA),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.code,
                              style: TextStyle(
                                color: AppColors.goldSoft,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _TrendPill(visual: visual, rate: rate),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '1 ${c.code} equals',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFFF6F3ED),
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      children: [
                        TextSpan(text: RateFormatter.rate(rate.rate)),
                        TextSpan(
                          text: '  EGP',
                          style: TextStyle(
                            color: AppColors.goldSoft,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // The day's change, spelled out in both EGP and percent.
                  if (rate.previousRate != null)
                    Row(
                      children: [
                        Icon(visual.icon, size: 15, color: visual.color),
                        const SizedBox(width: 5),
                        Text(
                          '${RateFormatter.signedChange(rate.changeAbsolute)}'
                          ' EGP · '
                          '${RateFormatter.signedPercent(rate.changePercent)}'
                          ' today',
                          style: TextStyle(
                            color: visual.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Last updated '
                        '${DateFormat('MMM d, y').format(lastUpdated)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.visual, required this.rate});

  final TrendVisual visual;
  final ExchangeRate rate;

  @override
  Widget build(BuildContext context) {
    final hasHistory = rate.previousRate != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: visual.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visual.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visual.icon, size: 14, color: visual.color),
          const SizedBox(width: 4),
          Text(
            hasHistory ? RateFormatter.signedPercent(rate.changePercent) : '—',
            style: TextStyle(
              color: visual.color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldFlag extends StatelessWidget {
  const _GoldFlag({required this.flag});

  final String flag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.goldSoft.withValues(alpha: 0.5)),
      ),
      child: Text(flag, style: const TextStyle(fontSize: 24)),
    );
  }
}

class _ChartError extends StatelessWidget {
  const _ChartError({super.key, this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            message ?? 'Chart unavailable',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  const _ChartEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'No history yet',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

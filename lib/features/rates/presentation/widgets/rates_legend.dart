import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A slim explainer under the hero: decodes the colored change badge and tells
/// the user the rows are tappable — two things the UI can't otherwise convey.
class RatesLegend extends StatelessWidget {
  const RatesLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brightness = theme.brightness;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _LegendItem(
                color: AppColors.up(brightness),
                icon: Icons.arrow_outward_rounded,
                label: 'EGP stronger',
              ),
              const SizedBox(width: 18),
              _LegendItem(
                color: AppColors.down(brightness),
                icon: Icons.south_east_rounded,
                label: 'EGP weaker',
              ),
              const Spacer(),
              Text(
                'vs. yesterday',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 15,
                color: AppColors.accent(brightness),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Tap a currency to see its 7-day trend',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

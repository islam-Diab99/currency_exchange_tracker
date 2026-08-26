import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton placeholder shown during the very first load, mirroring the shape
/// of the real header + cards so the transition to content is calm.
class RatesSkeleton extends StatelessWidget {
  const RatesSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = scheme.surfaceContainerLow;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      // One boundary keeps the animated gradient from repainting the app bar.
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const _Block(height: 176, radius: 24),
          const SizedBox(height: 6),
          for (var i = 0; i < itemCount; i++) const _Block(height: 76),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.height, this.radius = 20});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

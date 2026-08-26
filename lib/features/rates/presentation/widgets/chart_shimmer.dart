import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholder that mimics the real chart's anatomy — y-axis ticks,
/// a curved line with data points over a soft area fill, and x-axis date
/// labels — so the swap to live data is seamless rather than a flat block.
class ChartShimmer extends StatelessWidget {
  const ChartShimmer({super.key});

  // A fixed, pleasant silhouette (normalized 0..1, bottom-up).
  static const List<double> _shape = [0.45, 0.6, 0.5, 0.72, 0.58, 0.8, 0.7];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // y-axis tick placeholders
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 14,
                      top: 6,
                      bottom: 6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(4, (_) => const _Bar(width: 30)),
                    ),
                  ),
                  Expanded(
                    child: CustomPaint(painter: _CurveSkeletonPainter(_shape)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // x-axis date placeholders
            Padding(
              padding: const EdgeInsets.only(left: 44, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (_) => const _Bar(width: 26)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Paints a smoothed line (with dots) and its area fill in solid white; the
/// Shimmer parent masks the shimmer gradient over exactly these shapes.
class _CurveSkeletonPainter extends CustomPainter {
  const _CurveSkeletonPainter(this.shape);

  final List<double> shape;

  @override
  void paint(Canvas canvas, Size size) {
    // Faint horizontal grid lines.
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final pts = <Offset>[
      for (var i = 0; i < shape.length; i++)
        Offset(
          size.width * (i / (shape.length - 1)),
          size.height * (1 - shape[i]) * 0.82 + size.height * 0.06,
        ),
    ];

    // Smooth line path (mirrors fl_chart's curved look).
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      line.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Area fill under the line.
    final area = Path.from(line)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // The line itself.
    canvas.drawPath(
      line,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Data points.
    final dot = Paint()..color = Colors.white;
    for (final p in pts) {
      canvas.drawCircle(p, 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(_CurveSkeletonPainter oldDelegate) =>
      oldDelegate.shape != shape;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class VcosLogo extends StatelessWidget {
  const VcosLogo({
    this.size = 64,
    this.showTagline = false,
    super.key,
  });

  final double size;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final textScale = size / 64;
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.threadBrown,
          fontSize: 30 * textScale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          shadows: [
            const Shadow(
              color: Color(0x33000000),
              blurRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        );

    return Semantics(
      label: 'Logo VCOS, feito a mao com amor',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CustomPaint(
              painter: _PatchHeartPainter(),
            ),
          ),
          SizedBox(height: 4 * textScale),
          Text('VCOS', style: titleStyle),
          if (showTagline) ...[
            SizedBox(height: 2 * textScale),
            Text(
              'feito a mao com amor',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.threadBrown,
                    fontSize: 11 * textScale,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PatchHeartPainter extends CustomPainter {
  const _PatchHeartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final heart = Path()
      ..moveTo(size.width * 0.5, size.height * 0.86)
      ..cubicTo(
        size.width * 0.12,
        size.height * 0.58,
        size.width * 0.04,
        size.height * 0.28,
        size.width * 0.28,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.12,
        size.width * 0.5,
        size.height * 0.24,
        size.width * 0.5,
        size.height * 0.32,
      )
      ..cubicTo(
        size.width * 0.5,
        size.height * 0.24,
        size.width * 0.58,
        size.height * 0.12,
        size.width * 0.72,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.96,
        size.height * 0.28,
        size.width * 0.88,
        size.height * 0.58,
        size.width * 0.5,
        size.height * 0.86,
      )
      ..close();

    canvas.save();
    canvas.clipPath(heart);

    final patches = [
      (const Rect.fromLTWH(0, 0, 0.52, 0.48), AppColors.cherryPink),
      (const Rect.fromLTWH(0.48, 0, 0.52, 0.48), AppColors.honeyGold),
      (const Rect.fromLTWH(0, 0.42, 0.5, 0.58), AppColors.tealGreen),
      (const Rect.fromLTWH(0.42, 0.38, 0.3, 0.62), AppColors.blushPink),
      (const Rect.fromLTWH(0.68, 0.35, 0.32, 0.65), AppColors.grapePurple),
    ];

    for (final patch in patches) {
      canvas.drawRect(
        Rect.fromLTWH(
          patch.$1.left * size.width,
          patch.$1.top * size.height,
          patch.$1.width * size.width,
          patch.$1.height * size.height,
        ),
        Paint()..color = patch.$2,
      );
    }

    final seamPaint = Paint()
      ..color = AppColors.linen.withValues(alpha: 0.85)
      ..strokeWidth = math.max(1.2, size.width * 0.025)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.47, size.height * 0.08),
      Offset(size.width * 0.47, size.height * 0.9),
      seamPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.46),
      Offset(size.width * 0.9, size.height * 0.46),
      seamPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.14, size.height * 0.78),
      Offset(size.width * 0.82, size.height * 0.2),
      seamPaint,
    );

    canvas.restore();

    final outlinePaint = Paint()
      ..color = AppColors.threadBrown
      ..strokeWidth = math.max(1.6, size.width * 0.032)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(heart, outlinePaint);

    final stitchPaint = Paint()
      ..color = AppColors.linen
      ..strokeWidth = math.max(1, size.width * 0.018)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 34; i++) {
      final metric = heart.computeMetrics().first;
      final offset = metric.getTangentForOffset(metric.length * i / 34);
      if (offset == null) continue;
      final normal = Offset(-offset.vector.dy, offset.vector.dx);
      final start = offset.position - normal * size.width * 0.025;
      final end = offset.position + normal * size.width * 0.025;
      canvas.drawLine(start, end, stitchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

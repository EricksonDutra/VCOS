import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroPanel(
            icon: icon,
            title: title,
            description: description,
          ),
          const SizedBox(height: AppSpacing.lg),
          _StitchedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ColorSwatches(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '\u00c1rea pronta para come\u00e7ar',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Esta se\u00e7\u00e3o j\u00e1 segue o padr\u00e3o visual VCOS: letras grandes, contraste forte e espa\u00e7o confort\u00e1vel para tocar.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_rounded, size: 24),
                  label: Text(actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 420;
    final iconTile = _HeroIcon(icon: icon);

    return _StitchedCard(
      accent: AppColors.cherryPink,
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconTile,
                const SizedBox(height: AppSpacing.md),
                Text(title, style: theme.textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(description, style: theme.textTheme.bodyLarge),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconTile,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.headlineLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(description, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      hidden: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.tealGreen,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.threadBrown, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.threadBrown.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, size: 42, color: AppColors.white),
        ),
      ),
    );
  }
}

class _StitchedCard extends StatelessWidget {
  const _StitchedCard({
    required this.child,
    this.accent = AppColors.honeyGold,
  });

  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.linen,
      child: CustomPaint(
        painter: _StitchPainter(accent),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: child,
        ),
      ),
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.cherryPink,
      AppColors.tealGreen,
      AppColors.honeyGold,
      AppColors.grapePurple,
      AppColors.coralPink,
      AppColors.sageGreen,
      AppColors.blushPink,
      AppColors.linen,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) => _Swatch(color: color)).toList(),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
      shape: BoxShape.circle,
      border: Border.all(
          color: AppColors.threadBrown.withValues(alpha: 0.45),
          width: 2,
        ),
      ),
      child: const SizedBox.square(dimension: 32),
    );
  }
}

class _StitchPainter extends CustomPainter {
  const _StitchPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final border = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(22),
    ).deflate(10);
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()..addRRect(border);
    final metric = path.computeMetrics().first;
    for (var distance = 0.0; distance < metric.length; distance += 18) {
      final segment = metric.extractPath(distance, distance + 9);
      canvas.drawPath(segment, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StitchPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

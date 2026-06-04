import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/vcos_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/vcos_logo.dart';
import '../../shared/presentation/record_forms.dart';
import '../models/app_tabs.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    this.showSplash = true,
    super.key,
  });

  final bool showSplash;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  int _selectedIndex = 0;
  late bool _showSplash;

  @override
  void initState() {
    super.initState();
    _showSplash = widget.showSplash;
    if (!_showSplash) return;
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = appTabs[_selectedIndex];
    final controller = context.watch<VcosController>();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final tabTransitionDuration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 260);
    final splashDuration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 420);

    final message = controller.message;
    if (message != null && message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        context.read<VcosController>().clearMessage();
      });
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            titleSpacing: 18,
            title: Row(
              children: [
                const VcosLogo(size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedTab.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.creamBackground,
            ),
            child: CustomPaint(
              painter: const _GinghamBackgroundPainter(),
              child: SafeArea(
                child: AnimatedSwitcher(
                  duration: tabTransitionDuration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.03, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(selectedTab.label),
                    child: selectedTab.page,
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            height: 96,
            backgroundColor: AppColors.linen,
            indicatorColor: AppColors.blushPink,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: appTabs
                .map(
                  (tab) => NavigationDestination(
                    icon: Icon(tab.icon, semanticLabel: tab.label),
                    selectedIcon: _SelectedNavIcon(
                      icon: tab.icon,
                      reduceMotion: reduceMotion,
                    ),
                    label: tab.label,
                  ),
                )
                .toList(),
          ),
          floatingActionButton: AnimatedScale(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            scale: _showSplash ? 0.92 : 1,
            child: FloatingActionButton.extended(
              onPressed: () => _handlePrimaryAction(context),
              icon: const Icon(Icons.favorite_rounded, size: 24),
              label: Text(selectedTab.actionLabel),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: splashDuration,
          child: _showSplash ? const _SplashScreen() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _handlePrimaryAction(BuildContext context) {
    switch (_selectedIndex) {
      case 1:
        showSaleDialog(context);
        return;
      case 2:
        showExpenseDialog(context);
        return;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Use o botao Salvar configuracoes nesta tela.'),
          ),
        );
        return;
      default:
        showSaleDialog(context);
        return;
    }
  }
}

class _SelectedNavIcon extends StatelessWidget {
  const _SelectedNavIcon({
    required this.icon,
    required this.reduceMotion,
  });

  final IconData icon;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) {
      return Icon(icon, color: AppColors.cherryPink);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Icon(icon, color: AppColors.cherryPink),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ColoredBox(
      color: AppColors.creamBackground,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 850),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0, 1),
              child: Transform.scale(
                scale: 0.86 + (value * 0.14),
                child: child,
              ),
            );
          },
          child: const VcosLogo(size: 136, showTagline: true),
        ),
      ),
    );
  }
}

class _GinghamBackgroundPainter extends CustomPainter {
  const _GinghamBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const step = 36.0;
    final paint = Paint()..color = AppColors.coralPink.withValues(alpha: 0.035);

    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawRect(Rect.fromLTWH(x, 0, step / 2, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, step / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcos_app/core/theme/app_colors.dart';
import 'package:vcos_app/core/theme/app_spacing.dart';
import 'package:vcos_app/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('exposes the VCOS visual identity colors', () {
      expect(AppColors.cherryPink, const Color(0xFFC0395A));
      expect(AppColors.tealGreen, const Color(0xFF3A8C8C));
      expect(AppColors.creamBackground, const Color(0xFFFAF3E8));
      expect(AppColors.ink, const Color(0xFF1F1A1C));
    });
  });

  group('AppSpacing', () {
    test('keeps spacing tokens ordered from smallest to largest', () {
      expect(AppSpacing.xs, lessThan(AppSpacing.sm));
      expect(AppSpacing.sm, lessThan(AppSpacing.md));
      expect(AppSpacing.md, lessThan(AppSpacing.lg));
      expect(AppSpacing.lg, lessThan(AppSpacing.xl));
    });
  });

  group('AppTheme', () {
    test('uses the VCOS colors in the light color scheme', () {
      final theme = AppTheme.create(useGoogleFonts: false);

      expect(theme.colorScheme.primary, AppColors.cherryPink);
      expect(theme.colorScheme.secondary, AppColors.tealGreen);
      expect(theme.scaffoldBackgroundColor, AppColors.creamBackground);
      expect(theme.colorScheme.onSurface, AppColors.ink);
    });

    test('keeps readable minimum text sizes for low vision users', () {
      final textTheme = AppTheme.create(useGoogleFonts: false).textTheme;

      expect(textTheme.bodyMedium?.fontSize, greaterThanOrEqualTo(21));
      expect(textTheme.bodyLarge?.fontSize, greaterThanOrEqualTo(23));
      expect(textTheme.labelLarge?.fontSize, greaterThanOrEqualTo(20));
      expect(textTheme.titleMedium?.fontSize, greaterThanOrEqualTo(24));
      expect(textTheme.bodyMedium?.height, greaterThanOrEqualTo(1.45));
      expect(textTheme.bodyLarge?.height, greaterThanOrEqualTo(1.45));
    });

    test('uses large tap targets for primary actions', () {
      final buttonStyle =
          AppTheme.create(useGoogleFonts: false).elevatedButtonTheme.style;
      final minimumSize = buttonStyle?.minimumSize?.resolve({});

      expect(minimumSize?.height, greaterThanOrEqualTo(64));
    });

    test('keeps bottom navigation labels visible and large', () {
      final navTheme =
          AppTheme.create(useGoogleFonts: false).bottomNavigationBarTheme;

      expect(navTheme.showSelectedLabels, isTrue);
      expect(navTheme.showUnselectedLabels, isTrue);
      expect(navTheme.selectedLabelStyle?.fontSize, greaterThanOrEqualTo(18));
      expect(navTheme.unselectedLabelStyle?.fontSize, greaterThanOrEqualTo(18));
      expect(navTheme.selectedIconTheme?.size, greaterThanOrEqualTo(32));
      expect(navTheme.unselectedIconTheme?.size, greaterThanOrEqualTo(32));
    });

    test('uses extra large Material 3 navigation targets', () {
      final navTheme =
          AppTheme.create(useGoogleFonts: false).navigationBarTheme;
      final selectedStyle = navTheme.labelTextStyle?.resolve({
        WidgetState.selected,
      });
      final unselectedStyle = navTheme.labelTextStyle?.resolve({});
      final selectedIcon = navTheme.iconTheme?.resolve({WidgetState.selected});
      final unselectedIcon = navTheme.iconTheme?.resolve({});

      expect(selectedStyle?.fontSize, greaterThanOrEqualTo(19));
      expect(unselectedStyle?.fontSize, greaterThanOrEqualTo(19));
      expect(selectedIcon?.size, greaterThanOrEqualTo(36));
      expect(unselectedIcon?.size, greaterThanOrEqualTo(34));
    });
  });
}

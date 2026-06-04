import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => create();

  static ThemeData create({bool useGoogleFonts = true}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.cherryPink,
      primary: AppColors.cherryPink,
      secondary: AppColors.tealGreen,
      surface: AppColors.creamBackground,
      brightness: Brightness.light,
    ).copyWith(
      onPrimary: AppColors.white,
      onSecondary: AppColors.ink,
      onSurface: AppColors.ink,
    );

    final baseTextTheme = _baseTextTheme(useGoogleFonts);
    final titleTextTheme = _titleTextTheme(baseTextTheme, useGoogleFonts);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.creamBackground,
      focusColor: AppColors.grapePurple.withValues(alpha: 0.18),
      hoverColor: AppColors.honeyGold.withValues(alpha: 0.12),
      splashColor: AppColors.coralPink.withValues(alpha: 0.16),
      highlightColor: AppColors.honeyGold.withValues(alpha: 0.16),
      visualDensity: VisualDensity.comfortable,
      textTheme: baseTextTheme.copyWith(
        displayLarge: titleTextTheme.displayLarge?.copyWith(
          fontSize: 42,
          height: 1.16,
          fontWeight: FontWeight.w900,
          color: AppColors.threadBrown,
        ),
        headlineLarge: titleTextTheme.headlineLarge?.copyWith(
          fontSize: 36,
          height: 1.18,
          fontWeight: FontWeight.w900,
          color: AppColors.threadBrown,
        ),
        headlineMedium: titleTextTheme.headlineMedium?.copyWith(
          fontSize: 32,
          height: 1.2,
          fontWeight: FontWeight.w900,
          color: AppColors.threadBrown,
        ),
        titleLarge: titleTextTheme.titleLarge?.copyWith(
          fontSize: 28,
          height: 1.22,
          fontWeight: FontWeight.w900,
          color: AppColors.threadBrown,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 24,
          height: 1.28,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 23,
          height: 1.48,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 21,
          height: 1.5,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.creamBackground,
        foregroundColor: AppColors.threadBrown,
        elevation: 0,
        titleTextStyle: _titleStyle(useGoogleFonts).copyWith(
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w900,
          color: AppColors.threadBrown,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.linen,
        selectedItemColor: AppColors.cherryPink,
        unselectedItemColor: AppColors.threadBrown.withValues(alpha: 0.72),
        selectedIconTheme: const IconThemeData(size: 34),
        unselectedIconTheme: const IconThemeData(size: 32),
        selectedLabelStyle: _bodyStyle(useGoogleFonts).copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: _bodyStyle(useGoogleFonts).copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.linen,
        indicatorColor: AppColors.blushPink,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.cherryPink : AppColors.threadBrown,
            size: selected ? 36 : 34,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return _bodyStyle(useGoogleFonts).copyWith(
            color: selected ? AppColors.cherryPink : AppColors.threadBrown,
            fontSize: 19,
            height: 1.16,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          backgroundColor: AppColors.cherryPink,
          foregroundColor: AppColors.white,
          textStyle: _bodyStyle(useGoogleFonts).copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          foregroundColor: AppColors.threadBrown,
          side: const BorderSide(color: AppColors.cherryPink, width: 3),
          textStyle: _bodyStyle(useGoogleFonts).copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 22,
        ),
        labelStyle: _bodyStyle(useGoogleFonts).copyWith(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        hintStyle: _bodyStyle(useGoogleFonts).copyWith(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppColors.ink.withValues(alpha: 0.82),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.tealGreen, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.tealGreen, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.grapePurple, width: 4),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.linen,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: AppColors.threadBrown.withValues(alpha: 0.38),
            width: 2.5,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.honeyGold,
        foregroundColor: AppColors.threadBrown,
        extendedTextStyle: TextStyle(
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }

  static TextTheme _baseTextTheme(bool useGoogleFonts) {
    final textTheme = useGoogleFonts
        ? GoogleFonts.atkinsonHyperlegibleTextTheme()
        : ThemeData.light().textTheme;

    return textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
  }

  static TextTheme _titleTextTheme(
      TextTheme baseTextTheme, bool useGoogleFonts) {
    return useGoogleFonts
        ? GoogleFonts.atkinsonHyperlegibleTextTheme(baseTextTheme)
        : baseTextTheme;
  }

  static TextStyle _bodyStyle(bool useGoogleFonts) {
    return useGoogleFonts
        ? GoogleFonts.atkinsonHyperlegible()
        : const TextStyle(fontFamily: 'Arial');
  }

  static TextStyle _titleStyle(bool useGoogleFonts) {
    return useGoogleFonts
        ? GoogleFonts.atkinsonHyperlegible()
        : const TextStyle(fontFamily: 'Arial');
  }
}

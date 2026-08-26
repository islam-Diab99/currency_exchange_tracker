import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized Material 3 light/dark themes tuned for a luxury finish:
/// warm ivory or obsidian grounds, hairline borders instead of shadows, and a
/// champagne-gold accent.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.accent(brightness),
          surface: isDark ? AppColors.ink900 : AppColors.ivory,
          surfaceContainerLow: isDark
              ? AppColors.ink800
              : AppColors.ivorySurface,
          surfaceContainerHighest: isDark
              ? AppColors.ink700
              : const Color(0xFFEFE9DD),
          onSurface: isDark ? const Color(0xFFF1EEE8) : const Color(0xFF1A1917),
          onSurfaceVariant: isDark
              ? const Color(0xFF9A9488)
              : const Color(0xFF877F70),
          outlineVariant: isDark ? AppColors.inkBorder : AppColors.ivoryBorder,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink800,
        contentTextStyle: const TextStyle(color: Color(0xFFF1EEE8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

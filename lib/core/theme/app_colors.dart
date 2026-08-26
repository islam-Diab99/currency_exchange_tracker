import 'package:flutter/material.dart';

/// The palette for a refined, "private-banking" aesthetic: warm ivory and
/// obsidian grounds, a champagne-gold accent, and muted, sophisticated trend
/// tones (never loud red/green) that hold their elegance in both themes.
class AppColors {
  const AppColors._();

  // --- Brand accent (champagne gold) ---
  static const Color gold = Color(0xFFB68A3E);
  static const Color goldSoft = Color(0xFFC9A15B);
  static const Color goldBright = Color(0xFFE4C67E);

  /// Seed keeps Material components on-brand; surfaces are overridden by theme.
  static const Color seed = gold;

  // --- Obsidian scale (used for the hero "card" and dark theme) ---
  static const Color ink900 = Color(0xFF0B0D11);
  static const Color ink800 = Color(0xFF121620);
  static const Color ink700 = Color(0xFF1B2029);
  static const Color inkBorder = Color(0xFF262B34);

  // --- Ivory scale (light theme) ---
  static const Color ivory = Color(0xFFF6F3EC);
  static const Color ivorySurface = Color(0xFFFFFDF9);
  static const Color ivoryBorder = Color(0xFFEBE4D6);

  // --- Muted trend tones ---
  static const Color positive = Color(0xFF3F7D5C);
  static const Color positiveDark = Color(0xFF74C39A);
  static const Color negative = Color(0xFFB4544F);
  static const Color negativeDark = Color(0xFFDD9490);
  static const Color neutral = Color(0xFF9A9184);
  static const Color neutralDark = Color(0xFF8B8578);

  static Color up(Brightness b) =>
      b == Brightness.dark ? positiveDark : positive;

  static Color down(Brightness b) =>
      b == Brightness.dark ? negativeDark : negative;

  static Color muted(Brightness b) =>
      b == Brightness.dark ? neutralDark : neutral;

  /// Gold tuned for legibility on the current ground.
  static Color accent(Brightness b) => b == Brightness.dark ? goldSoft : gold;
}

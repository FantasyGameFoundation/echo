import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const ivory = Color(0xFFF6F1E8);
    const graphite = Color(0xFF1B1A17);
    const moss = Color(0xFF51634D);
    const clay = Color(0xFFB56B45);

    final scheme = ColorScheme.fromSeed(
      seedColor: moss,
      brightness: Brightness.light,
      primary: moss,
      secondary: clay,
      surface: ivory,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ivory,
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: .78),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: graphite.withValues(alpha: .08),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.45,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: graphite.withValues(alpha: .08)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        backgroundColor: Colors.white.withValues(alpha: .7),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: graphite,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: graphite,
          side: BorderSide(color: graphite.withValues(alpha: .14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData dark() {
    const ink = Color(0xFF121313);
    const smoke = Color(0xFFEFE6D8);
    const moss = Color(0xFF9EB08D);
    const clay = Color(0xFFE09A72);

    final scheme = ColorScheme.fromSeed(
      seedColor: moss,
      brightness: Brightness.dark,
      primary: moss,
      secondary: clay,
      surface: ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: .05),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: smoke.withValues(alpha: .08),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.45,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: smoke.withValues(alpha: .08)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        backgroundColor: Colors.white.withValues(alpha: .06),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: smoke,
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: smoke,
          side: BorderSide(color: smoke.withValues(alpha: .14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

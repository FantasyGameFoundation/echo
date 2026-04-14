import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF7F7F9),
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5A5A5A),
        brightness: Brightness.light,
      ),
    );
  }
}
